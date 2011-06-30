LineItem.class_eval do

  def gift_wrap?
    order.gift_wrap?
  end

  def gift_message
    "I love you so much!"
  end
end
