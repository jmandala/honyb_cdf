class PoaAddressLine < ActiveRecord::Base
  include PoaRecord
  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_address_line do |l|
      l.trap { |line| line[0, 2] == '32' }
      l.template :poa_defaults_plus
      l.recipient_address_line 35
      l.spacer 16
    end
  end
end
