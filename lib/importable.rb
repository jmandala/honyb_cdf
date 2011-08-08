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
      puts "this is the class: #{self.class}"
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

          # to do: Error if file already exists
          file = self.find_or_create_by_file_name(file)

          files << file
          ftp.delete file
        end
      end

      files
    end

    def add_delimiters(path)
      data = read_contents path
      return if data.length <= record_length
      delimited_data = data.scan(/#{record_length}/).join("\r\n")
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
      puts "the class is #{self.class}"

      out = ''
      File.open(path, 'r') do |file|
        while line = file.gets
          out << line
        end
      end
      out
    end


    def class_method
      puts 'the class method'
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
    Rails.logger.debug p

    populate_file_header p
    errors = []
    self.class.collaborators.each do |klass|
      Rails.logger.debug "importing #{klass.name}"
      err = klass.populate p, self
      err.each { |e| errors << e }
    end

    self.imported_at = Time.now
    save!

    errors
  end


  def instance_method
    puts 'the instance method'
  end

  def combo
    instance_method
    puts self.class
    self.class.class_method
  end

end


