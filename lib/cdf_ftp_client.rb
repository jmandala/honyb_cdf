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
    session = Net::FTP.new(@server)
    session.login(@user, @password)
    session.close
  end
end