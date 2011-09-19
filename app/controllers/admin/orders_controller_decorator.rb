#noinspection RubyResolve
Admin::OrdersController.class_eval do

  def fulfillment
    logger.debug "fulfillment!"
  end
  
end