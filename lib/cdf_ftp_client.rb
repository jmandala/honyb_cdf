require 'net/ftp'

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

  def connect
    return if mock?
    
    Net::FTP.open(@server) do |ftp|
      ftp.login @user, @password
      yield ftp if block_given?
    end
  end


end