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
    self.tracking = data[:tracking].strip
    data.delete :tracking

    init_shipment
  end

  def available_shipment_query
    sql = "order_id = :order_id AND shipped_at IS NULL"
    params = {:order_id => self.order.id}

    # match shipping methods if one exists
    if self.shipping_method
      sql += " AND shipping_method_id = :shipping_method_id"
      params[:shipping_method_id] = self.shipping_method.id
    end

    # match any shipment with no tracking number, or the same tracking number
    if self.tracking
      sql += " AND (tracking IS NULL OR tracking = :tracking)"
      params[:tracking] = self.tracking
    end

    Shipment.where(sql, params)
  end

  # Returns shipments that are available for assignment to this object.
  # The constraints are:
  # * the shipping method matches
  # * AND the order matches
  # * AND there is NO tracking number on the shipment and no tracking number on this object
  def available_shipment

    sql = available_shipment_query
    shipment_count = sql.count

    Rails.logger.warn "Found #{shipment_count} shipments, but expected 1: #{sql}" if shipment_count > 1

    sql.order('created_at asc').first
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
    assign_inventory

    # if there are no inventory_units, delete the shipment
    if self.shipment.inventory_units.count == 0
      self.shipment.delete
      return
    end

    self.shipment.transfer_sold_to_child
    self.shipment.save!

    assign_shipment

    self.save!
    self.shipment
  end

  def shipped?
    if self.asn_order_status
      return self.asn_order_status.shipped? || self.asn_order_status.partial_shipment?
    end

    false
  end

  def shipment_date
    self.asn_shipment.shipment_date if self.asn_shipment
  end

  # assigns [Shipment] to this [AsnShipmentDetail]
  # * as a result the shipment will be marked as shipped
  # * the tracking number will be set
  # * the inventory will be allocated
  def assign_shipment
    raise Cdf::IllegalStateError, "Error attempting to ship shipment #{shipment.number}. Current state: #{shipment.state}" unless self.shipment.can_ship?

    # save the shipment status
    self.shipment.state = 'shipped'
    self.shipment.update!(order)

    # reload the shipments on the order in order to prevent stale shipments from clobbering this new one 
    self.shipment.order.shipments.reload
    self.shipment.tracking = self.tracking if self.tracking
    self.shipment.shipped_at = self.shipment_date

    self.shipment.save!

  end


  # assigns inventory from [Shipment] to this [AsnShipmentDetail]
  # * consider inventory only if the state is 'sold'
  # * assign enough inventory to satisfy #quantity_shipped, or raise exception
  # * if no available shipments exist, creat one
  def assign_inventory
    self.shipment = self.available_shipment

    # assign the inventory from the [Shipment] or if not available from the []Order]   
    self.quantity_shipped.times do
      assign_inventory_by_type(:shipped)
    end

    self.quantity_slashed.times do
      assign_inventory_by_type(:slashed)
    end

  end

  def assign_inventory_by_type(type)
    inventory_unit = self.shipment.inventory_units.sold(self.variant).limit(1).first if shipment

    inventory_unit ||= self.order.inventory_units.sold(self.variant).limit(1).first

    raise Cdf::IllegalStateError, "Must have inventory units to assign!: #{order.shipments.count}" if inventory_unit.nil?

    if type == :shipped
      self.inventory_units << inventory_unit
      self.shipment ||= new_shipment_for_order(inventory_unit)
      self.shipment.inventory_units << inventory_unit unless self.shipment.inventory_units.include?(inventory_unit)
      inventory_unit.ship!

      # canceled, slashed
    else
      inventory_unit.slash
      inventory_unit.delete
    end

    self.save!

  end


  # Returns the shipment that will be considered the parent of the shipment associated with this object
  # A parent is any shipment on the same order, with the same shipping method, shipped within 1 day of this shipment
  def find_parent_shipment
    sql = "order_id = :order_id AND shipped_at = :shipped_at"
    params = {:order_id => self.order.id, :shipped_at => self.shipment_date}

    # match shipping methods if one exists
    if self.shipping_method
      sql += " AND shipping_method_id = :shipment_id"
      params[:shipment_id] = self.shipping_method.id
    end

    Shipment.where(sql, params).order('created_at asc').first
  end

  def new_shipment_for_order(inventory_unit)
    parent = find_parent_shipment
    return parent.create_child([inventory_unit]) if parent

    Shipment.create(:address => self.order.ship_address, :order => self.order, :shipping_method => self.shipping_method, :inventory_units => [inventory_unit])
  end

end
