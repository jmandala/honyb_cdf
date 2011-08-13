class AsnShipmentDetail < ActiveRecord::Base
  include AsnRecord

  belongs_to :line_item
  belongs_to :order
  belongs_to :asn_file
  has_one :product, :through => :line_item
  belongs_to :asn_order_status_code
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
      l.scac 5
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
    status = AsnOrderStatus.find_by_code(data[:item_detail_status_code])
    data[:asn_order_status_id] = status.id unless status.nil?

    slash_code = AsnSlashCode.find_by_code(data[:shipping_method_or_slash_reason_code])
    data[:asn_slash_code_id] = slash_code.id unless slash_code.nil?

    shipping_method_code = AsnSlashCode.find_by_code(data[:shipping_method_or_slash_reason_code])
    data[:asn_shipping_code_id] = shipping_method_code.id unless slash_code.nil?

    order = Order.find_by_number(data[:client_order_id])
    data[:order_id] = order.id unless order.nil?

    dc_code = DcCode.find_by_poa_dc_code(data[:shipping_warehouse_code])
    data[:dc_code_id] = dc_code.id unless dc_code.nil?

    line_item = LineItem.find_by_id(data[:line_item_id_number])
    data[:line_item_id] = line_item.id unless line_item.nil?
  end

end
