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
    
    # Added by Josh Jacobs to address conditions when inventory was assigned and then canceled
    # by the fulfilment department    
    event :cancel do
      transition all => 'canceled', :from => 'sold'
    end

    after_transition :on => :fill_backorder, :do => :update_order
    after_transition :to => 'returned', :do => :restock_variant

    # Added by Josh Jacobs to address conditions when inventory was assigned
    # but canceled by the fulfilment department. These items will never be shipped, 
    # and should be restocked.
    after_transition :to => 'canceled', :do => :restock_variant    
    after_transition :on => :cancel, :do => :update_order    
  end
  
  # all inventory of a specific variant (optional) that is in the 'sold' state
  def self.sold(variant=nil)
    arel = where(:state => 'sold')
    arel = arel.where(:variant_id => variant.id) if variant
    arel
  end
  

end
