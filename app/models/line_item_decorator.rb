LineItem.class_eval do

  has_many :asn_shipment_details, :dependent => :restrict
  has_many :poa_line_items, :dependent => :restrict

  def gift_wrap?
    order.gift_wrap?
  end

  def gift_message
    "I love you so much!"
  end
end
