#noinspection RubyResolve
Admin::OrdersController.class_eval do

  before_filter :init_paging
  
  helper :data_view
  
  def fulfillment
    logger.debug "fulfillment!"
  end
  
  
  private
  def init_paging
    params['orders_per_page'] ||= Spree::Config[:orders_per_page]
    
    if params['orders_per_page'] != Spree::Config[:orders_per_page]
      Spree::Config.set({:orders_per_page => params['orders_per_page']})
    end
    
  end
end