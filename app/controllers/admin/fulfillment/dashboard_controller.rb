class Admin::Fulfillment::DashboardController < Admin::BaseController
  respond_to :html, :xml, :json

  def index
    @needs_po_count = Order.needs_po.count
    @po_files = PoFile.find(:all)
    client = CdfFtpClient.new({:keep_alive => true})
    begin
      @outgoing_files = client.outgoing_files
      @test_files = client.test_files
      @archive_files = client.archive_files
      @incoming_files = client.archive_files
      client.close
    rescue => e
      flash[:error] = e.message
      redirect_to admin_fulfillment_settings_path
      return
    end
    respond_with @po_files

  end

end