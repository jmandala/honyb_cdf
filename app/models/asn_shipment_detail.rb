class AsnShipmentDetail < ActiveRecord::Base
  include AsnRecord
  include Records

  belongs_to :line_item
  belongs_to :order
  has_many :inventory_units
  belongs_to :asn_file
  belongs_to :asn_shipment
  belongs_to :shipment
  belongs_to :asn_order_status
  belongs_to :asn_slash_code
  belongs_to :asn_shipping_method_code
  belongs_to :dc_code

  def self.spec(d)
    d.asn_shipment_detail do |l|
      l.trap { |line| line[0, 2] == 'OD' }
      l.template :asn_defaults
      l.shipping_warehouse_code 2
      l.ingram_order_entry_number 10
      l.quantity_canceled 5
      l.isbn_10_ordered 10
      l.isbn_10_shipped 10
      l.quantity_predicted 5
      l.quantity_slashed 5
      l.quantity_shipped 5
      l.item_detail_status_code 2
      l.tracking 25
      l.standard_carrier_address_code 5
      l.spacer 15
      l.ingram_item_list_price 7
      l.net_discounted_price 7
      l.line_item_id_number 10
      l.ssl 20
      l.weight 9
      l.shipping_method_or_slash_reason_code 2
      l.isbn_13 15
      l.spacer 7
    end
  end

  def before_populate(data)
    self.asn_shipment = nearest_asn_shipment(data[:__LINE_NUMBER__])

    [:ingram_item_list_price, :net_discounted_price, :weight].each do |key|
      self.send("#{key}=", self.class.as_cdf_money(data, key))
      data.delete key
    end

    self.asn_order_status = AsnOrderStatus.find_by_code(data[:item_detail_status_code])
    data.delete :status

    self.asn_slash_code = AsnSlashCode.find_by_code(data[:shipping_method_or_slash_reason_code])
    if !self.asn_slash_code
      self.asn_shipping_method_code = AsnShippingMethodCode.find_by_code(data[:shipping_method_or_slash_reason_code])
    end
    data.delete :shipping_method_or_slash_reason_code

    self.order = Order.find_by_number!(data[:client_order_id])
    data.delete :client_order_id

    self.dc_code = DcCode.find_by_asn_dc_code(data[:shipping_warehouse_code])
    if self.dc_code.nil?
      # try with just the first digit due to spec inconsistency
      first = data[:shipping_warehouse_code].match(/./).to_s
      codes = DcCode.where("asn_dc_code LIKE ?", "#{first}%")
      if codes.count
        self.dc_code = codes.first
      end
    end
    data.delete :shipping_warehouse_code

    line_items = LineItem.find_by_id(data[:line_item_id_number])
    self.line_item = line_items
    data.delete :line_item_id_number

    [:quantity_canceled,
     :quantity_predicted,
     :quantity_slashed,
     :quantity_shipped].each do |field|
      value = data[field]
      if value.empty?
        self.send "#{field}=", 0
      else
        self.send "#{field}=", value.to_i
      end
      data.delete field
    end

    # make sure tracking code is set
    self.tracking = data[:tracking]
    data.delete :tracking
    
    init_shipment
  end

  # Returns shipments that are available for assignment to this object.
  # The constraints are:
  # * the shipping method matches
  # * AND the order matches
  # * AND there is NO tracking number on the shipment and no tracking number on this object
  def available_shipments
    if shipping_method.nil?
      return []
    end

    # the first shipment related to the AsnShipmentDetail will have no tracking number and will not be shipped
    # subsequent shipments will be identified by having the same tracking number
    sql = "order_id = #{self.order.id} AND shipping_method_id = #{self.shipping_method.id}"

    # match tracking number if there is one    
    sql += " AND tracking = '#{self.tracking}'" unless self.tracking.nil?
    
    Shipment.where(sql)
  end

  def shipping_method
    self.asn_shipping_method_code.shipping_method unless self.asn_shipping_method_code.nil?
  end

  # All [AsnShipmentDetail]s that don't yet have []Shipment]s
  def self.missing_shipment
    where(:shipment_id => nil)
  end

  # helper method to retrieve the product assigned to the line_item
  def product
    line_item.product unless line_item.nil?
  end

  # helper method to retrieve the variant assigned to the line_item
  def variant
    line_item.variant unless line_item.nil?
  end

  # assigns the correct shipment to this object
  # matches the first available shipment
  def init_shipment
    if shipped?
      assignable_shipments = self.available_shipments
      if assignable_shipments.empty?
        # Shipment must use a shipping method that is a copy of the original method
        # but which only bills for multiple-packages
        shipments = [Shipment.create(:address_id => self.order.ship_address_id, :order_id => self.order_id, :shipping_method_id => self.shipping_method.id)]
      else
        shipments = assignable_shipments
      end

      shipments.each do |shipment|
        assign_inventory shipment
        assign_shipment shipment
      end

    else
      raise Cdf::IllegalStateError, "Cannot init_shipment for status: #{self.asn_order_status.to_yaml}"

      # todo: Cancel items that did not ship and which were truly canceled
    end

    self.save!

    self.shipment
  end

  def shipped?
    if self.asn_order_status
      return self.asn_order_status.shipped?
    end

    false
  end

# assigns [Shipment] to this []AsnShipmentDetail]
# * as a result the shipment will be marked as shipped
# * the tracking number will be set
# * the inventory will be allocated
  def assign_shipment(shipment)
    self.shipment = shipment

    shipment.tracking = self.tracking
    #shipment.shipped_at = self.asn_shipment.shipment_date

    begin
      #raise StandardError, shipment.to_yaml
      #shipment.ship! unless shipment.state?('shipped')
    rescue => e
      raise Cdf::IllegalStateError, "Error attempting to import #{self.asn_file.file_name}::#{self.isbn_13}: #{self.tracking}, (#{shipment.state}) - #{e.message}"
    end

    shipment.save!
  end

# assigns inventory from [Shipment] to this [AsnShipmentDetail]]
# * consider inventory only if the state is 'sold'
# * assign enough inventory to satisfy #quantity_shipped, or raise exception
  def assign_inventory(shipment)

    shipment.unassign_sold_inventory

    # assign one inventory unit from the [Order] ]for each quantity shipped of the given product    
    self.quantity_shipped.times do
      self.order.inventory_units.sold(self.variant).each do |inventory_unit|
        self.inventory_units << inventory_unit
        shipment.inventory_units << inventory_unit
      end
    end

    self.save!
  end

end
