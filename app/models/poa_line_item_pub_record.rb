class PoaLineItemPubRecord < ActiveRecord::Base
  include Updateable

  belongs_to :poa_order_header
end
