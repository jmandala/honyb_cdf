Admin::OrdersController.class_eval do

  def fulfillment
    logger.debug "fulfillment!"
  end

  # POST /admin/orders
  # Creates a new set of orders for Fulfillment testing
  def generate_test_orders
    order = Cdf::OrderFactory.new
    order.save!
    
    flash[:notice] = "Created 1 test order"
    
    redirect_to :action => :index, :search =>  {:order_type_equals => :test} 
  end

end