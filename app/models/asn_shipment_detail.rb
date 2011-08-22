class AsnShipmentDetail < ActiveRecord::Base
  include AsnRecord
  include Records

  belongs_to :line_item
  belongs_to :order
  belongs_to :asn_file
  has_one :product, :through => :line_item
  belongs_to :asn_order_status
  belongs_to :asn_slash_code
  belongs_to :asn_shipping_method_code
  belongs_to :dc_code

  def self.spec(d)
    d.asn_shipment_detail do |l|
      l.trap {|line| line[0,2] == 'OD'}
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

    self.dc_code = DcCode.find_by_poa_dc_code(data[:shipping_warehouse_code])
    data.delete :shipping_warehouse_code

    self.line_item = LineItem.find_by_id(data[:line_item_id_number])
    data.delete :line_item_id_number

    if data[:quantity_canceled].empty?
      self.quantity_canceled = 0
    end
    data.delete :quantity_canceled

  end

end
