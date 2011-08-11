class PoaAdditionalDetail < ActiveRecord::Base
  include Updateable
  include Records
  extend PoaRecord
  
  belongs_to :poa_order_header
  belongs_to :poa_line_item
  delegate :poa_file, :to => :poa_order_header

  def self.spec(d)
    d.poa_additional_detail do |l|
      l.trap {|line| line[0,2] == '41'}
      l.template :poa_defaults_plus
      l.spacer 4
      l.availability_date 6
      l.spacer 1
      l.dc_inventory_information 40
    end
  end

  def before_populate(data)
    self.class.as_cdf_date data, :availability_date
    self.poa_line_item = nearest_poa_line_item
  end

  # Returns the [PoaLineItem] from the same [PoaOrderHeader] with the sequence that is
  # closest to this record's sequence, without being great
  def nearest_poa_line_item
    PoaLineItem.
        where(:poa_order_header_id => self.poa_order_header_id).
        where("sequence_number < :sequence_number", {:sequence_number => self.sequence_number}).
        order("sequence_number DESC").
        limit(1).first
  end
end

