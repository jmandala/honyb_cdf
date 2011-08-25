class PoaAdditionalDetail < ActiveRecord::Base
  include Updateable
  include Records
  include PoaRecord

  belongs_to :poa_order_header
  belongs_to :poa_line_item
  delegate :poa_file, :to => :poa_order_header

  def self.spec(d)
    d.poa_additional_detail do |l|
      l.trap { |line| line[0, 2] == '41' }
      l.template :poa_defaults_plus
      l.spacer 4
      l.availability_date 6
      l.spacer 1
      l.dc_inventory_information 40
    end
  end

  def before_populate(data)
    self.class.as_cdf_date data, :availability_date
    data.delete :availability_date
    self.poa_line_item = nearest_poa_line_item
  end
end

