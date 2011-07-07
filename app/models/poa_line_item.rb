class PoaLineItem < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_status
  belongs_to :dc_code
  belongs_to :product

  after_save :save_debug

  def self.spec(d)
    d.poa_line_item do |l|
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

  def after_populate(data)
    #logger.debug "#{data[:line_item_po_number]} : #{line_item_po_number}"
    #logger.debug "after populate poa_line_item"
    #dc_code = DcCode.find_by_poa_dc_code(data[:dc_code])
    #logger.debug "Looked for DcCode with code: #{data[:dc_code]}. Found: #{dc_code.inspect}"

    #poa_status = PoaStatus.find_by_code(data[:poa_status])
  end

  def save_debug
    #logger.debug inspect
  end
end
