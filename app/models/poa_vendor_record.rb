class PoaVendorRecord< ActiveRecord::Base
  include PoaRecord

  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_vendor_record(:optional =>true) do |l|
      l.trap { |line| line[0, 2] == '21' }
      l.template :poa_defaults_plus
      l.vendor_message 50
      l.spacer 1
    end
  end

end
