# Record 42
class PoaLineItemTitleRecord < ActiveRecord::Base
  include PoaRecord

  belongs_to :poa_order_header
  belongs_to :cdf_binding_code
  belongs_to :poa_line_item
  delegate :poa_file, :to => :poa_order_header

  def self.spec(d)
    d.poa_line_item_title_record do |l|
      l.trap { |line| line[0, 2] == '42' }
      l.template :poa_defaults_plus
      l.title 30
      l.author 20
      l.binding_code 1
    end
  end

  def before_populate(data)
    binding = CdfBindingCode.find_by_code(data[:binding_code])
    self.cdf_binding_code = binding.first unless binding.nil?
    self.cdf_binding_code ||= CdfBindingCode.other
    self.poa_line_item = nearest_poa_line_item
  end
end
