class Po29 < CdfRecord


  def to_s
    cdf_record
  end

  def cdf_record
    cdf = super
    cdf << purchaser_city
    cdf << purchaser_state
    cdf << purchaser_postal_code
    cdf << purchaser_country
    cdf << reserved(9)
  end

  def purchaser_city
    @order.bill_address.city.ljust 25
  end

  def purchaser_postal_code
    @order.bill_address.zipcode.ljust 11
  end

  def purchaser_state
    @order.bill_address.state.abbr.ljust(3)
  end

  def purchaser_country
    @order.bill_address.country.iso3
  end
end