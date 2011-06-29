class Admin::FulfillmentController < Admin::BaseController

  def index
    @orders = Order.complete.limit(1)
  end

  def show
    
  end
end