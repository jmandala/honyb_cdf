InventoryUnit.class_eval do

  belongs_to :asn_shipment_detail

  # all inventory of a specific variant (optional) that is in the 'sold' state
  def self.sold(variant=nil)
    arel = where(:state => 'sold')
    arel = arel.where(:variant_id => variant.id) if variant
    arel
  end
  
  def slash
    restock_variant
  end

end
