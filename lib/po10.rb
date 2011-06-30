# Client Header
class Po10 < CdfRecord

  def to_s
    cdf_record
  end

  def cdf_record
    cdf = super
    cdf << ingram_bill_to_account_number
    cdf << vendor_san
    cdf << order_date
    cdf << backorder_cancel_date
    cdf << backorder_code
    cdf << ddc_fulfillment
    cdf << reserved(7)
    cdf << reserved(2)
    cdf << ship_to_indicator
    cdf << bill_to_indicator
    cdf << reserved(6)
    cdf << reserved(1)
    cdf << reserved(5)
  end

  def ingram_bill_to_account_number
    "1234567"
  end

  def order_date
    cdf_date @order.completed_at
  end

  def vendor_san
    "1697978"
  end

  def backorder_cancel_date
    cdf_date(@order.completed_at + 3.months)
  end

  # N = do not backorder
  # B = Backorder only Not Yet Released (NYR) items.
  # Y = Backorder all items that are not available to ship
  # Blank = default
  def backorder_code
    "N" # do not backorder
  end

  # DDC FulFillment or "Split Line Ordering"
  # Must be "N"
  def ddc_fulfillment
    "N"
  end

  # Must be "Y", indicates presence of records 30 through 38
  def ship_to_indicator
    "Y"
  end

  # Must be "Y"
  def bill_to_indicator
    "Y"
  end


end