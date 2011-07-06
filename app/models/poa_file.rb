class PoaFile < ActiveRecord::Base

  attr_reader :data


  # connect to remote server
  # retrieve all files
  # save to data_lib
  # create records for each file
  def self.download

  end

  def path
    "#{CdfConfig::data_lib_in_root(created_at.strftime("%Y"))}/#{file_name}"
  end

  def load_file
    raise ArgumentError, "File not found: #{path}"  unless File.exists?(path)

    @data = ''
    File.open(path, 'r') do |file|
      while line = file.gets
        @data << line
      end
    end
    @data
  end



end