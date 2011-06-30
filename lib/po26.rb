# Consumer Bill To Phone Number
class Po26 < CdfRecord

  def to_s
    cdf_record
  end

  def cdf_record
    cdf = super
    cdf << purchaser_phone_number
    cdf << reserved(26)
  end


  def purchaser_phone_number
    @order.bill_address.phone.ljust 25
  end

end