class PoaLineItemPubRecord < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_line_item_pub_record do |l|
      l.trap { |line| line[0, 2] == '43' }
      l.template :poa_defaults_plus
      l.publisher_name 20
      l.publication_release_date 4
      l.original_seq_number 5
      l.spacer 4
      l.total_qty_predicted_to_ship_primary 7
      l.spacer 11
    end
  end

  def before_populate(data)
    if !data[:publication_release_date].empty?
      data[:publication_release_date] = Time.strptime(data[:publication_release_date], "%m%y")
    end

  end

end
