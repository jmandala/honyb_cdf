require 'net/ftp'

module Cdf
  class InvalidCredentials < StandardError
  end
  class InvalidServer < StandardError
  end
  class MissingFile < StandardError
  end
end

class CdfFtpClient

  attr_reader :server, :user, :password

  def run_mode
    Cdf::Config[:cdf_run_mode].to_sym
  end

  def mock?
    run_mode == :mock
  end

  def live?
    run_mode == :live
  end

  def test?
    run_mode == :test
  end

  def initialize(opts={})
    @keep_alive = opts[:keep_alive] || false
    @server = Cdf::Config[:cdf_ftp_server]
    @user = Cdf::Config[:cdf_ftp_user]
    @password = Cdf::Config[:cdf_ftp_password]
    @ftp = nil
  end

  # Makes a connection and yields the block given, if there is one
  # If #mock? then returns nil and does nothing
  # Raises []ArgumentError] if credentials are invalid
  def connect
    return if mock?

    if !@ftp || !@keep_alive
      @ftp = login!
    end

    begin
      yield @ftp if block_given?
    rescue => e
      raise ArgumentError, "Unable to perform FTP commands: #{e.class}: #{e.message}"
    ensure
      @ftp.close if @ftp && !@keep_alive
    end
  end

  # Returns all files in the 'outgoing' folder
  def outgoing_files
    dir '~/outgoing'
  end

  # Returns all files in the 'test' folder
  def test_files
    dir '~/test'
  end

  # Returns all files in the 'archive' folder
  def archive_files
    dir '~/archive'
  end

  # Returns all files in the 'incoming' folder
  def incoming_files
    dir '~/incoming'
  end

  # @param list [Array]
  # @param regexp [String]
  def files_from_dir_list(list, regexp)
    files = []
    list.each do |file|
      file_name = name_from_path(file)
      files << file_name if !regexp || regexp && file =~ /#{regexp}$/
    end
    files
  end


  def dir(dir=nil, regexp=nil)
    files = []
    connect do |ftp|
      ftp.chdir dir if dir
      ftp.list.each do |file|
        file_name = name_from_path(file)
        files << file if !regexp || regexp && file_name =~ /#{regexp}$/
      end
    end
    files
  end

  # Uploads the local file to the remote path
  # @param local_file [String]
  # @param remote_path [String]
  # @return nil
  def put(remote_path, local_file)
    raise Cdf::MissingFile, "Can't locate local file #{local_file}." unless File.exists? local_file

    connect do |ftp|
      ftp.put File.new(local_file), File.join(remote_path, File.basename(local_file))
    end
  end

  def delete(remote_path, file_name)
    connect do |ftp|
      ftp.delete(File.join(remote_path, file_name))
    end
  end

  def get(remote_path, local_path)
    @ftp ||= open!

    @ftp.get remote_path, local_path
    
    local_path
  end

  # Downloads the file 
  def get_all(remote_path, mask, local_dir='.')
    FileUtils.mkdir_p local_dir

    @ftp ||= open!

    downloaded = []

    dir(remote_path, mask).each do |path|
      file_name = name_from_path(path)
      @ftp.get File.join(remote_path, file_name), File.join(local_dir, file_name)
      downloaded << file_name
    end

    downloaded
  end

  def name_from_path(file)
    file.split[file.split.length-1]
  end

  def open?
    !@ftp.nil? && !@ftp.closed?
  end

  def close
    @ftp.close if @ftp
    @ftp = nil
  end

  def valid_server?
    return true if mock?
    
    begin
      ftp = open!
      ftp.close
      return true
    rescue Cdf::InvalidServer => e
      return false
    end
  end

  # Returns true if login is successful or in mock? state, otherwise false
  def valid_credentials?
    return true if mock?

    begin
      ftp = login!
      ftp.close
      return true
    rescue Cdf::InvalidCredentials => e
      return false
    end

  end


  # Returns an open ftp connection, or raises an ArgumentError if unable to connect
  def open!
    begin
      ftp = Net::FTP.open @server
      return ftp
    rescue => e
      ftp.close if ftp
      raise Cdf::InvalidServer, "Unable to establish connection to server: '#{@server}' (#{e.class}: #{e.message})."
    end
  end

  # Returns a logged in ftp connection, or raises an ArgumentError if unable to connect
  def login!(ftp=nil)
    begin
      ftp ||= open!
      ftp.login @user, @password
      return ftp
    rescue Cdf::InvalidServer => e
      raise e
    rescue => e
      ftp.close if ftp
      raise Cdf::InvalidCredentials, "Unable to establish connection to server: '#{@server}' with username: #{@user}."
    end
  end

end