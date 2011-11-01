#noinspection RubyResolve
Admin::OrdersController.class_eval do

  before_filter :init_paging
  before_filter :load_order, :only => [:duplicate]
  
  helper :data_view
  
  def fulfillment
    logger.debug "fulfillment!"
  end

  def duplicate
    number = @order.number
    @order = @order.duplicate
    flash.notice = t('order_duplicated', :number => number)
    redirect_to admin_order_url(@order)    
  end
  
  
  
  private
  def init_paging
    params['orders_per_page'] ||= Spree::Config[:orders_per_page]
    
    if params['orders_per_page'] != Spree::Config[:orders_per_page]
      Spree::Config.set({:orders_per_page => params['orders_per_page']})
    end
    
  end
end