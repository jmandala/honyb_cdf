#noinspection RubyResolve
Admin::OrdersController.class_eval do

  def fulfillment
    logger.debug "fulfillment!"
  end

  # POST /admin/orders
  # Creates a new set of orders for Fulfillment testing
  def generate_test_orders
    puts params[:scenario].to_yaml
    orders = Cdf::OrderBuilder.create_for_scenarios params[:scenarios]
    
    flash[:notice] = "Created #{orders.count} test orders"
    
    redirect_to :action => :index, :search =>  {:order_type_equals => :test} 
  end

end