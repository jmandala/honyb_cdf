class PoaLineItem < ActiveRecord::Base
  include Updateable

  belongs_to :poa_order_header
  belongs_to :poa_status
  belongs_to :dc_code
  belongs_to :product
end
