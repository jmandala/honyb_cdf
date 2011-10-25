Shipment.class_eval do

  has_many :children, :class_name => Shipment.name, :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => Shipment.name, :foreign_key => 'parent_id'

  # overwriting core method in order to prevent email from being sent each time
  # the shipment is marked shipped
  # AsnShipmentDetail will be responsible for sending the shipment emails
  def after_ship
    inventory_units.each {|u| u.ship! unless u.state?('shipped') }
  end
 
  def create_child(inventory_units)
    child = Shipment.create!(
        :order => order, 
        :shipping_method => shipping_method,
        :address => address,
        :inventory_units => inventory_units,
        :parent => self
    )
    self.children << child
    child
  end

  def inventory_units_shipped
    inventory_units_shipped = {}
    self.inventory_units.all.each do |iu|
      next unless iu.shipped?
      key = iu.variant.sku
      result = inventory_units_shipped[key]
      count = result[:count] if result
      count ||= 0
      count += 1
      inventory_units_shipped[key] = {:inventory_unit => iu, :count => count} 
    end
    inventory_units_shipped
  end
  
  # Removes any []InventoryUnit]s that have status 'sold'
  # and adds them to a child shipment
  def transfer_sold_to_child
    sold_units = self.inventory_units.sold.all
    sold_units.each { |u| self.inventory_units.delete(u) }
    self.create_child(sold_units)
  end
  
end