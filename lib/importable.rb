require 'fileutils'

module Importable
  #noinspection RubyResolve
  include Updateable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def collaborator(*classes)
      @collaborators ||= []
      @collaborators << classes
    end

    def collaborators
      @collaborators.flatten
    end

    def definition_name
      self.model_name.i18n_key
    end

    # Returns a file mask that will match import files with the correct extension
    def file_mask
      "*#{@ext}"
    end

    def define_ext(extension)
      @ext = extension
    end

    def ext
      @ext
    end

    def define_length(length)
      @record_length = length
    end

    def record_length
      @record_length
    end

    def import_format
      FixedWidth.define definition_name do |d|
        yield d

        self.collaborators.each { |klass| klass.spec d }
      end
    end

    def files
      Dir.glob(CdfConfig::current_data_lib_in + "/**/" + file_mask)
    end

    def name_from_path(file)
      file.split[file.split.length-1]
    end

    # Returns an array of remote file names including only files with an extension of @@ext
    def remote_files
      client = CdfFtpClient.new({:keep_alive => true})
      files = []
      ['test', 'outgoing'].each do |dir|
        remote_dir = "~/#{dir}"
        files += client.dir(remote_dir, ".*#{@ext}")
      end
      client.close
      files
    end


    def remote_file_path
      'outgoing'
    end

    def remote_file_list(ftp)
      ftp.chdir remote_file_path
      files_from_dir_list(ftp.list(file_mask))
    end

    def remote_test_file_list(ftp)
      ftp.chdir test_dir
      files_from_dir_list(ftp.list(file_mask))
    end

    def remote_outgoing_file_list(ftp)
      ftp.chdir outgoing_dir
      files_from_dir_list(ftp.list(file_mask))
    end

    def outgoing_dir
      '~/outgoing'
    end

    def test_dir
      '~/test'
    end

    # Downloads all remote files in the 'outgoing' directory
    # matching the file_mask
    #
    #Returns a list of files that were downloaded
    def download
      CdfConfig::ensure_path CdfConfig::current_data_lib_in

      client = CdfFtpClient.new({:keep_alive => true})

      files = []
      [outgoing_dir, test_dir].each do |remote_dir|
        download_from_dir(client, remote_dir).each { |file| files << file }
      end
      files
    end

    def download_from_dir(client, remote_dir)
      remote_listing = client.dir remote_dir, ".*#{@ext}"
      files = []
      remote_listing.each do |listing|
        file = client.name_from_path listing

        import_file = self.new_or_archived(file)

        local_path = create_path file
        remote_path = File.join(remote_dir, file)
        client.get remote_path, local_path
        write_data_with_delimiters local_path

        files << import_file

        client.delete remote_dir, file
      end
      files
    end

    def new_or_archived(file)
      import_file = self.find_by_file_name(file)

      if import_file
        import_file = import_file.archive_with_new_file file
      else
        import_file = self.create(:file_name => file)
      end

      import_file
    end

    # Updates the contents of path to include record terminators
    def write_data_with_delimiters(path)
      data = read_contents(path)
      write_data path, data
    end

    # Returns data with record terminators
    def add_delimiters(data)
      return data if data.split(/\n/)[0].length <= record_length
      data.scan(/.{#{record_length}}/).join("\r\n")
    end

    # Writes data to path, adding record terminators
    def write_data(path, data)
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)

      raise ArgumentError, "Invalid file path '#{path}'" unless File.exists?(path)
      data = add_delimiters data
      File.open(path, 'w') { |f| f.write(data) }
    end

    def files_from_dir_list(list)
      files = []
      list.each do |file|
        file_name = self.name_from_path(file)
        if file_name =~ /#{@ext}$/
          files << file_name
        end
      end
      files
    end

    # @return [String] the location to save this file
    def create_path(file_name)
      File.join CdfConfig::current_data_lib_in, file_name
    end

    def needs_import
      where("#{self.table_name}.imported_at IS NULL")
    end


    def read_contents(path)
      File.read path
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

  # @return true if import file contains error messages 
  def import_error?
    data == 'NO MAINFRAME'
  end

  def import_error_message
    if data == 'NO MAINFRAME'
      'NO MAINFRAME'
    end
  end

  def import
    if import_error?
      return CdfImportExceptionLog.create(:event => "Error importing file: #{import_error_message}", :file_name => self.file_name)
    end

    begin
      p = parsed

      populate_file_header p
      imported = []
      self.class.collaborators.each do |klass|
        begin
          imported << klass.populate(p, self)
        rescue => e
          message = "Error importing #{klass}. #{e.message}. #{e.backtrace.slice(0, 15)}"
          Rails.logger.error message
          Rails.logger.error e.backtrace.slice(0, 15)
          CdfImportExceptionLog.create(:event => message, :file_name => self.file_name)
          raise e, message, e.backtrace
        end

      end

      #noinspection RubyResolve
      self.imported_at = Time.now
      save!

      imported
    rescue => e
      CdfImportExceptionLog.create(:event => e.message, :file_name => self.file_name, :backtrace => e.backtrace)
      raise e
    end
  end

  def import!
    result = import
    if result.class == CdfImportExceptionLog
      raise StandardError, result.event, result.backtrace
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

  def write_data(data)
    self.class.write_data path, data
  end

end


