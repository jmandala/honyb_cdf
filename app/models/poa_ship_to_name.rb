class PoaShipToName < ActiveRecord::Base
  include PoaRecord
  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_ship_to_name do |l|
      l.trap { |line| line[0, 2] == '30' }
      l.template :poa_defaults_plus
      l.recipient_name 35
      l.spacer 15
      l.spacer 1
    end
  end

end
