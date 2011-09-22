class PoaItemNumberPriceRecord < ActiveRecord::Base
  include PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_line_item

  def self.spec(d)
    d.poa_item_number_price_record do |l|
      l.trap { |line| line[0, 2] == '44' }
      l.template :poa_defaults_plus
      l.spacer 20
      l.net_price 8
      l.item_number_type 2
      l.discounted_list_price 8
      l.total_line_order_qty 7
      l.spacer 6
    end
  end

  def before_populate(data)
    self.poa_line_item = nearest_poa_line_item
  end
  
end
