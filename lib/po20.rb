# Optional
# Fixed Special Handling Instructions
class Po20 < CdfRecord



  def to_s
    cdf_record
  end

  def cdf_record
    cdf = String.new
    cdf << record_code
    cdf << sequence_number
    cdf << po_number
    cdf << special_handling_codes
    cdf << reserved(21)
  end

  def record_code
    "20"
  end

  def special_handling_codes
    reserved(30)
  end

end