class Admin::FulfillmentController < Admin::BaseController

  def index
    @needs_po_count = Order.needs_po.count
    @po_files = PoFile.find(:all)
  end

  def create_po
    @po = PoFile.generate
  end

  def show_po
    @po = PoFile.find(params[:id])
  end
end