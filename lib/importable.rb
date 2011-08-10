require 'fileutils'

module Importable
  include Updateable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def collaborator(*classes)
      @@collaborators ||= []
      @@collaborators << classes
    end

    def collaborators
      @@collaborators.flatten
    end

    def definition_name
      self.model_name.i18n_key
    end

    # Returns a file mask that will match import files with the correct extension
    def file_mask
      "*#{@@ext}"
    end

    def define_ext(extension)
      @@ext = extension
    end

    def ext
      @@ext
    end


    def define_length(length)
      @@record_length = length
    end

    def record_length
      @@record_length
    end

    def import_format
      FixedWidth.define definition_name do |d|
        yield d

        self.collaborators.each do |klass|
          klass.spec d
        end
      end
    end


    def files
      Rails.logger.debug "FileMask: #{file_mask}"
      Dir.glob(CdfConfig::current_data_lib_in + "/**/" + file_mask)
    end

    def name_from_path(file)
      file.split[file.split.length-1]
    end

    # Returns an array of remote file names including only files with an extension of @@ext
    def remote_files
      client = CdfFtpClient.new
      files = []
      client.connect do |ftp|
        files = remote_file_list ftp
      end
      files
    end

    def remote_file_list(ftp)
      ftp.chdir 'outgoing'
      files_from_dir_list(ftp.list(file_mask))
    end

    # Downloads all remote files in the 'outgoing' directory
    # matching the file_mask
    #
    #Returns a list of files that were downloaded
    def download
      CdfConfig::ensure_path CdfConfig::current_data_lib_in

      files = []
      CdfFtpClient.new.connect do |ftp|
        remote_file_list(ftp).each do |file|
          local_path = create_path file
          ftp.gettextfile(file, local_path)

          add_delimiters local_path


          import_file = self.find_by_file_name(file)

          if import_file
            import_file = import_file.archive_with_new_file file
          else
            import_file = self.create(:file_name => file)
          end

          
          files << import_file
          ftp.delete file
        end
      end

      files
    end

    def add_delimiters(path)
      data = read_contents path
      return if data.length <= record_length
      delimited_data = data.scan(/.{#{record_length}}/).join("\r\n")
      File.open(path, 'w') { |f| f.write(delimited_data) }
    end

    def files_from_dir_list(list)
      files = []
      list.each do |file|
        file_name = self.name_from_path(file)
        if file_name =~ /#{@@ext}$/
          files << file_name
        end
      end
      files
    end

    def create_path(file_name)
      File.join CdfConfig::current_data_lib_in, file_name
    end

    def needs_import
      where("#{self.table_name}.imported_at IS NULL")
    end


    def read_contents(path)
      out = ''
      File.open(path, 'r') do |file|
        while line = file.gets
          out << line
        end
      end
      out
    end

    def import_all
      imported = []
      self.needs_import.each do |i|
        imported << i.import
      end
      imported
    end

  end


  def data
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)
    return @data unless @data.nil? || @data.empty?
    @data = self.class.read_contents path
  end


  def path
    File.join CdfConfig::data_lib_in_root(created_at.strftime("%Y")), file_name
  end

  def populate_file_header(p)
    update_from_hash p[:header].first
  end

  # Read the file data and build the record
  def parsed
    FixedWidth.parse(File.new(path), self.class.definition_name)
  end

  def import
    p = parsed

    populate_file_header p
    imported = []
    self.class.collaborators.each do |klass|
      imported << klass.populate(p, self)
    end

    self.imported_at = Time.now
    save!

    imported
  end

  def import!
    errors = self.import

    if errors
      raise StandardError, 'failed to import'
    end
  end

  def archive_with_new_file(file)
    import_file = self.class.create(:file_name => file)
    import_file.versions << self

    create_archive import_file
  end

  def create_archive(parent)
    new_path = self.class.create_path archive_file_name
    FileUtils.mv(orig_path, new_path)

    self.file_name = archive_file_name
    self.parent = parent
    save!
  end

  def archive_file_name
    count = versions.count > 0 ? versions.count : 1
    "#{file_name}.#{count}"
  end

  def orig_path
    self.class.create_path file_name
  end

end


