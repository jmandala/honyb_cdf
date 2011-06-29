# Purchase Order Options Record
class Po24 < CdfRecord

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
    cdf << sales_tax_percent
    cdf << freight_tax_percent
    cdf << freight_amount
    cdf << reserved(28)
  end

  def record_code
    "24"
  end

  def sales_tax_percent
    if @order.tax_rate
      return sprintf("%08d", @order.tax_rate.amount)
    end

    sprintf("%08.4f", 0)
  end

  def freight_tax_percent
    sprintf("%07.4f", 0)
  end

  def freight_amount
    sprintf("%08.2f", @order.ship_total)
  end

end