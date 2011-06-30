module Records
  class PoMessage < CdfRecord
    def cdf_record
      cdf = super
      cdf << message
    end

    def message
      @options[:message].ljust_trim 51
    end
  end
end