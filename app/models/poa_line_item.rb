# Record Code 40
class PoaLineItem < ActiveRecord::Base
  include PoaRecord
  
  belongs_to :poa_order_header
  belongs_to :poa_status
  belongs_to :dc_code
  belongs_to :line_item
  has_one :poa_line_item_title_record
  has_one :poa_line_item_pub_record
  has_one :poa_additional_detail
  has_one :poa_item_number_price_record
  delegate_belongs_to :poa_order_header, :order
  delegate_belongs_to :poa_order_header, :poa_file
  delegate_belongs_to :line_item, :variant

  def self.spec(d)
    d.poa_line_item(:singular => false) do |l|
      l.trap { |line| line[0, 2] == '40' }
      l.template :poa_defaults_plus
      l.line_item_po_number 10
      l.spacer 12
      l.line_item_item_number 20
      l.spacer 3
      l.spacer 3
      l.poa_status 2
      l.dc_code 1
    end
  end

  def before_populate(data)
    self.poa_status = PoaStatus.find_by_code!(data[:poa_status])
    data.delete :poa_status

    self.dc_code = DcCode.find_by_poa_dc_code!(data[:dc_code])
    data.delete :dc_code

    self.line_item = LineItem.find_by_id!(data[:line_item_po_number].strip)
  end

end
