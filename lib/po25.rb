class Po25 < CdfRecord


  def to_s
    cdf_record
  end

  def cdf_record
    cdf = String.new
    cdf << record_code
    cdf << sequence_number
    cdf << po_number
    cdf << purchasing_consumer_name
    cdf << reserved(16)
  end

  def record_code
    "25"
  end

  def purchasing_consumer_name
    "#{@order.bill_address.firstname} #{@order.bill_address.lastname}".ljust 35
  end

end