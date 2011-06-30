# Consumer Bill To Address Line
class Po27 < CdfRecord

  def to_s
    cdf_record
  end

  def cdf_record
    cdf = super
    cdf << purchaser_address_line
    cdf << reserved(16)
  end

  def purchaser_address_line
    @order.bill_address.send(address_line).ljust 35
  end

  def address_line
    @options[:address_line] || :address1
  end

end