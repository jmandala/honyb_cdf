#noinspection RubyResolve
Admin::OrdersController.class_eval do

  helper :data_view
  
  def fulfillment
    logger.debug "fulfillment!"
  end
  
end