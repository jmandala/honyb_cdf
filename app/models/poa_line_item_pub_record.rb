class PoaLineItemPubRecord < ActiveRecord::Base
  include PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_line_item
  delegate :poa_file, :to => :poa_order_header

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
    import_date = data[:publication_release_date]
    if !import_date.empty? && import_date.match(/^\d4/)
      self.publication_release_date = Time.strptime(import_date, "%m%y")
    end
    data.delete :publication_release_date

    self.poa_line_item = nearest_poa_line_item
  end

end
