class Admin::Fulfillment::DashboardController < Admin::BaseController
  respond_to :html, :xml, :json

  def index
    @needs_po_count = Order.needs_po.count
    @submit_po_count = PoFile.not_submitted.count
    @po_files = PoFile.find(:all)
    respond_with @po_files
  end

end