class CdfRecord

  def initialize(order, sequence, args)
    @order = order
    @sequence = sequence
    @options = args
  end

  def reserved(size)
    sprintf("%#{size.to_s}s", "")
  end

  def cdf_date(date)
    date.strftime '%Y%m%d'
  end

  def sequence_number
    sprintf("%05d", @sequence)
  end


  def po_number
    sprintf("%22d", @order.id)
  end

end