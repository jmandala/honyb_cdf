class PoaOrderControlTotal < ActiveRecord::Base
  include PoaRecord
  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_order_control_total do |l|
      l.trap do |line|
        line[0, 2] == '59'
      end
      l.template :poa_defaults_plus
      l.record_count 5
      l.total_line_items_in_file 10
      l.total_units_acknowledged 10
      l.spacer 10
      l.spacer 8
      l.spacer 8
    end
  end

end
