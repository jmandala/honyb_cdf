class PoaCityStateZip < ActiveRecord::Base
  include PoaRecord
  belongs_to :poa_order_header
  belongs_to :state
  belongs_to :country

  def self.spec(d)
    d.poa_city_state_zip do |l|
      l.trap { |line| line[0, 2] == '34' }
      l.template :poa_defaults_plus
      l.recipient_city 25
      l.recipient_state_province 3
      l.zip_postal_code 11
      l.country 3
      l.spacer 9
    end
  end

  def before_populate(data)
    state = State.find_by_abbr(data[:recipient_state_province])
    data[:state_id] = state.id unless state.nil?

    country = Country.find_by_iso(data[:country])
    data[:country_id] = country.id unless country.nil?
  end

end
