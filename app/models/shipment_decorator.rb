Shipment.class_eval do


  # overwriting core method in order to prevent email from being sent each time
  # the shipment is marked shipped
  # AsnShipmentDetail will be responsible for sending the shipment emails
  def after_ship
    inventory_units.each &:ship!
    self.shipped_at = Time.now
  end


end