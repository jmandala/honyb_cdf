class AsnShipment < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :asn_file
  belongs_to :order

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
    poa_status = PoaStatus.find_by_code(data[:poa_status])
    data[:poa_status_id] = poa_status.id unless poa_status.nil?

    dc_code = DcCode.find_by_poa_dc_code(data[:dc_code])
    data[:dc_code_id] = dc_code.id unless dc_code.nil?

    line_item = LineItem.find_by_id(data[:line_item_po_number])
    data[:line_item_id] = line_item.id unless line_item.nil?
  end

end
