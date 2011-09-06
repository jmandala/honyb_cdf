require 'net/ftp'

module Cdf
  class InvalidCredentials < StandardError; end
  class InvalidServer < StandardError; end
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

  def initialize
    @server = Cdf::Config.instance.preferences['cdf_ftp_server']
    @user = Cdf::Config.instance.preferences['cdf_ftp_user']
    @password = Cdf::Config.instance.preferences['cdf_ftp_password']
  end

  # Makes a connection and yields the block given, if there is one
  # If #mock? then returns nil and does nothing
  # Raises []ArgumentError] if credentials are invalid
  def connect
    return if mock?

    ftp = login!
    begin
      yield ftp if block_given?
    rescue => e
      raise ArgumentError, "Unable to perform FTP commands: #{e.class}: #{e.message}"
    ensure
      ftp.close if ftp
    end

  end

  def valid_server?
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