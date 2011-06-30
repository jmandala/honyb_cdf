# Marketing Message Record -- repeat as necessary up to 5 times
class Po37 < CdfRecord
  def cdf_record
    cdf = super
    cdf << message
    cdf
  end

  def message
    @options[:message].ljust_trim 51
  end

end