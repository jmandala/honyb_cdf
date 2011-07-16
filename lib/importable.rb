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
      err.each {|e| errors << e}
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
    end
  end
end