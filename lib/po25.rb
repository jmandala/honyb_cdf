# Consumer Bill To Name
class Po25 < CdfRecord

  def cdf_record
    cdf = super
    cdf << purchasing_consumer_name
    cdf << reserved(16)
  end


  def purchasing_consumer_name
    "#{@order.bill_address.firstname} #{@order.bill_address.lastname}".ljust 35
  end

end