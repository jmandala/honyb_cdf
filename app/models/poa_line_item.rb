# Record Code 40
class PoaLineItem < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_status
  belongs_to :dc_code
  belongs_to :line_item
  delegate_belongs_to :poa_order_header, :order
  delegate_belongs_to :line_item, :variant

  def self.spec(d)
    d.poa_line_item(:singular => false) do |l|
      l.trap {|line| line[0,2] == '40'}
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
    self.dc_code = DcCode.find_by_poa_dc_code!(data[:dc_code])
    self.line_item = LineItem.find_by_id!(data[:line_item_po_number])
    self.save!
  end

end
