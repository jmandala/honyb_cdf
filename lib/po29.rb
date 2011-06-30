class Po29 < CdfRecord

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
    cdf << purchaser_city
    cdf << purchaser_state
    cdf << purchaser_postal_code
    cdf << purchaser_country
    cdf << reserved(16)
  end

  def record_code
    "25"
  end

  def purchaser_city
    @order.bill_address.city.ljust 25
  end

  def purchaser_postal_code
    @order.bill_address.zipcode.ljust 11
  end

  def purchaser_state
    @order.bill_address.state.abbr
  end

  def purchaser_country
    @order.bill_address.country.iso3
  end
end