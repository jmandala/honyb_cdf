class AsnShipment < ActiveRecord::Base
  include Updateable
  extend AsnRecord

  belongs_to :asn_file
  belongs_to :order
  belongs_to :asn_order_status

  def self.spec(d)
    d.asn_shipment do |l|
      l.trap {|line| line[0,2] == 'OR' }
      l.template :asn_defaults
      l.spacer 8
      l.order_status_code 2
      l.order_subtotal 8
      l.spacer 8
      l.spacer 8
      l.spacer 8
      l.order_discount_amount 8
      l.sales_tax 8
      l.shipping_and_handling 8
      l.order_total 8
      l.freight_charge 8
      l.spacer 3
      l.total_item_detail_count 4
      l.shipment_date 8
      l.consumer_po_number 22
      l.spacer 56
    end
  end

  def before_populate(data)
    status = AsnOrderStatus.find_by_code(data[:order_status_code])
    data[:asn_order_status_id] = status.id unless status.nil?

    order = Order.find_by_number(data[:client_order_id])
    data[:order_id] = order.id unless order.nil?
  end
end
