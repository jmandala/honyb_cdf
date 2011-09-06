require 'net/ftp'

class CdfFtpClient

  attr_reader :server, :user, :password

  def initialize
    @server = Cdf::Config.instance.preferences['cdf_ftp_server']
    @user = Cdf::Config.instance.preferences['cdf_ftp_user']
    @password = Cdf::Config.instance.preferences['cdf_ftp_password']
  end

  def connect
    Net::FTP.open(@server) do |ftp|
      ftp.login @user, @password
      yield ftp if block_given?
    end
  end


end