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
      l.tracking_number 25
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

    init_shipment(data[:tracking_number])
  end

  # returns any unassigned shipments in the same order, with the same shipping method, and the same tracking number
  def available_shipments
    if shipping_method.nil?
      return []
    end

    # the first shipment related to the AsnShipmentDetail will have no tracking number and will not be shipped
    # subsequent shipments will be identified by having the same tracking number
    Shipment.where("order_id = #{self.order.id}
      AND shipping_method_id = #{self.shipping_method.id}
      AND (shipped_at IS NULL OR tracking = '#{self.tracking_number}')")
  end

  def shipping_method
    asn_shipping_method_code.shipping_method unless asn_shipping_method_code.nil?
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
  def init_shipment(tracking)
    if shipped?
      if self.available_shipments.empty?
        raise Cdf::IllegalStateError, "failed to create shipments because none found! #{self.tracking_number}"
        
        # todo: Create a new shipment to assign these products to
        # Shipment must use a shipping method that is a copy of the original method
        # but which only bills for multiple-packages
        
      end
      self.available_shipments.each do |shipment|
        assign_shipment shipment, tracking
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

  # assigns [Shipment] to this AsnShipmentDetail
  # * as a result the shipment will be marked as shipped
  # * the tracking number will be set
  # * the inventory will be allocated
  def assign_shipment(shipment, tracking)
    self.shipment = shipment
    
    # todo: assign inventory units to this shipment corresponding to the number of items actually shipped
    shipment.tracking = tracking
    shipment.shipped_at = Time.now
    begin
      shipment.ship! unless shipment.state?('shipped')
    rescue => e
      raise Cdf::IllegalStateError, "Error attempting to import #{self.asn_file.file_name}::#{self.isbn_13}: #{tracking}, #{e.message}"
    end

    shipment.save!
  end

end
