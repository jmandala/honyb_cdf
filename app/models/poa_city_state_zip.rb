class PoaCityStateZip < ActiveRecord::Base
  include Updateable

  belongs_to :poa_order_header
  belongs_to :state
  belongs_to :country
end
