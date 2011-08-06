module Importable
  include Updateable

  def data
    raise ArgumentError, "File not found: #{path}" unless File.exists?(path)

    return @data unless @data.nil? || @data.empty?

    @data = ''
    File.open(path, 'r') do |file|
      while line = file.gets
        @data << line
      end
    end
    @data
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

  def self.included(base)
    base.class_eval do
      def self.collaborator(*classes)
        @@collaborators ||= []
        @@collaborators << classes
      end

      def self.collaborators
        @@collaborators.flatten
      end

      def self.definition_name
        self.model_name.i18n_key
      end

      def self.file_mask(mask)
        @@mask = mask
      end

      def self.import_format
        FixedWidth.define definition_name do |d|
          yield d

          self.collaborators.each do |klass|
            klass.spec d
          end
        end
      end

      def self.files
        Rails.logger.debug "FileMask: #{@@mask}"
        Dir.glob(CdfConfig::current_data_lib_in + "/**/" + @@mask)
      end

      def self.name_from_path(file)
        file.split[file.split.length-1]
      end

      # Returns an array of remote file names including only files with an extension of @@ext
      def self.remote_files
        client = CdfFtpClient.new
        files = []
        client.connect do |ftp|
          files = remote_file_list ftp
        end
        files
      end

      def self.remote_file_list(ftp)
        ftp.chdir 'outgoing'
        return files_from_dir_list(ftp.list("*#{@@ext}"))
      end

      # Returns a list of files that were downloaded
      def self.download
        CdfConfig::ensure_path CdfConfig::current_data_lib_in

        files = []
        CdfFtpClient.new.connect do |ftp|
          remote_file_list(ftp).each do |file|
            local_path = create_path file
            ftp.gettextfile(file, local_path)
            
            # to do: Error if file already exists
            files << self.find_or_create_by_file_name(file)

            ftp.rm file

          end
        end

        logger.debug 'done'

        files
      end

      def self.files_from_dir_list(list)
        files = []
        list.each do |file|
          file_name = self.name_from_path(file)
          if file_name =~ /#{@@ext}$/
            files << file_name
          end
        end
        return files
      end

      def self.create_path(file_name)
        File.join CdfConfig::current_data_lib_in, file_name
      end

      def self.needs_import
        where("#{self.table_name}.imported_at IS NULL")
      end

    end
  end
end