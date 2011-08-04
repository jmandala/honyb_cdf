require 'net/ftp'

class CdfFtpClient

  attr_reader :server, :user, :password

  def initialize(connection = nil)
    @server = Spree::Config.get :cdf_ftp_server
    @user = Spree::Config.get :cdf_ftp_user
    @password = Spree::Config.get :cdf_ftp_password

    @connection = connection || Net::FTP
    if connection

    end
  end

  def connect
    Net::FTP.open(@server) do |ftp|
      ftp.login Spree::Config[:cdf_ftp_user], Spree::Config[:cdf_ftp_password]
      yield ftp if block_given?
    end
  end


end