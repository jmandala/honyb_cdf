class Admin::FulfillmentController < Admin::BaseController

  def index
    manager = Cdf::Manager.new
    @po = manager.generate_po
  end

  def show
    
  end
end