class AsnShipmentDetail < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :line_item
  belongs_to :order
  belongs_to :asn_file
  belongs_to :product

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
    poa_status = PoaStatus.find_by_code(data[:poa_status])
    data[:poa_status_id] = poa_status.id unless poa_status.nil?

    dc_code = DcCode.find_by_poa_dc_code(data[:dc_code])
    data[:dc_code_id] = dc_code.id unless dc_code.nil?

    line_item = LineItem.find_by_id(data[:line_item_po_number])
    data[:line_item_id] = line_item.id unless line_item.nil?
  end

end
