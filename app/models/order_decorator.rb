Order.class_eval do

  def to_cdf(sequence)
    PoRecord.new(self, sequence).to_s
  end


end
