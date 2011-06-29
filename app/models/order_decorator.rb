Order.class_eval do

  def to_cdf(sequence)
    PoRecord.new(self, sequence).to_s
  end


  def tax_rate
    TaxRate.match(ship_address).first
  end

end
