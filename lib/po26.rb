class Po26 < CdfRecord

  def initialize(order, sequence)
    @order = order
    @sequence = sequence
  end

  def to_s
    cdf_record
  end

  def cdf_record
    cdf = String.new
    cdf << record_code
    cdf << sequence_number
    cdf << po_number
    cdf << purchaser_phone_number
    cdf << reserved(26)
  end

  def record_code
    "25"
  end

  def purchaser_phone_number
    @order.bill_address.phone.ljust 25
  end

end