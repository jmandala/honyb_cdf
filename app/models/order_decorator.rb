Order.class_eval do

  def as_cdf(start_sequence = 1)
    Cdf::Records::PoRecord.new(self, start_sequence)
  end

  def tax_rate
    TaxRate.match(ship_address).first
  end

  def gift_wrap_fee
    0
  end

  def is_gift?
    false
  end

  def gift_wrap?
    false
  end

  def gift_message
    "Enjoy your gifts!"
  end

  def total_quantity
   line_items.inject(0) { |sum, l| sum + l.quantity }
  end

end
