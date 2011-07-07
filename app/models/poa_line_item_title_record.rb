class PoaLineItemTitleRecord < ActiveRecord::Base
  include Updateable
  extend PoaRecord

  belongs_to :poa_order_header

  belongs_to :cdf_binding_code

  def self.spec(d)
    d.poa_line_item_title_record do |l|
      l.trap {|line| line[0,2] == '42'}
      l.template :poa_defaults_plus
      l.title 30
      l.author 20
      l.binding_code 1
    end
  end

  def before_populate(data)
    cdf_binding_code = CdfBindingCode.find_by_code(data[:binding_code])
    data[:cdf_binding_code_id] = cdf_binding_code.id unless cdf_binding_code.nil?
  end
end
