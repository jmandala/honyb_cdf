class Po27 < CdfRecord

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
    @order.bill_address.send(address_line).ljust 35
  end

  def address_line
    @options[:address_line] || :address1
  end

end