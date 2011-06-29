class Po27 < CdfRecord

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
    cdf << purchaser_address_line
    cdf << reserved(16)
  end

  def record_code
    "25"
  end

  def purchaser_address_line
    @order.bill_address.one_line_street.ljust 35
  end

end