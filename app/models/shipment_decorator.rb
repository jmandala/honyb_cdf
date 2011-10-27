Shipment.class_eval do

  has_many :children, :class_name => Shipment.name, :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => Shipment.name, :foreign_key => 'parent_id'

  # overwriting core method in order to prevent email from being sent each time
  # the shipment is marked shipped
  # AsnShipmentDetail will be responsible for sending the shipment emails
  def after_ship
    inventory_units.each { |u| u.ship! if u.can_ship? && !u.state?('shipped') }
  end

  def create_child(inventory_units)
    child = Shipment.new(
        :order => order,
        :shipping_method => shipping_method,
        :address => address,
        :parent => self
    )
    child.inventory_units = inventory_units
    child.save!
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
    return unless self.inventory_units.sold.count > 0
    sold_units = self.inventory_units.sold.all
    sold_units.each { |u| self.inventory_units.delete(u) }
    self.create_child(sold_units)
  end


  def debug_shipment_state(message)

    log = lambda { "#{message}: [current = #{self.state} / db = #{Shipment.find(self).state}]"}

    if block_given?
      self.class.debug "BEFORE: #{log.call}"
      yield
      self.class.debug "AFTER: #{log.call}"
    else
      self.class.debug log.call
    end
  end

  def self.debug(log)
    puts log
    Rails.logger.debug "\n#{log}"
  end

  def self.debug_shipment_state(shipment, message)
    shipment.debug_shipment_state message if shipment
  end
end