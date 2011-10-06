InventoryUnit.class_eval do

  belongs_to :asn_shipment_detail


  # state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'on_hand' do
    event :fill_backorder do
      transition :to => 'sold', :from => 'backordered'
    end
    event :ship do
      transition :to => 'shipped', :if => :allow_ship?
    end
    event :return do
      transition :to => 'returned', :from => 'shipped'
    end
    
    event :cancel do
      transition all => 'canceled'
    end

    after_transition :on => :fill_backorder, :do => :update_order
    after_transition :to => 'returned', :do => :restock_variant

    after_transition :to => 'canceled', :do => :restock_variant    
    after_transition :on => :cancel, :do => :update_order    
  end


end
