class PoaLineItem < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_status
  belongs_to :dc_code
  belongs_to :line_item

  def self.spec(d)
    d.poa_line_item(:singular => false) do |l|
      l.trap do |line|
        puts @singular
        line[0,2] == '40'

      end
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
    poa_status = PoaStatus.find_by_code(data[:poa_status])
    data[:poa_status_id] = poa_status.id unless poa_status.nil?

    dc_code = DcCode.find_by_poa_dc_code(data[:dc_code])
    data[:dc_code_id] = dc_code.id unless dc_code.nil?

    line_item = LineItem.find_by_id(data[:line_item_po_number])
    data[:line_item_id] = line_item.id unless line_item.nil?
  end

end
