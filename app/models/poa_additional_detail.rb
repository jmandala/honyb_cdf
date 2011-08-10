class PoaAdditionalDetail < ActiveRecord::Base
  include Updateable
  extend PoaRecord
  
  belongs_to :poa_order_header

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
  end
end

