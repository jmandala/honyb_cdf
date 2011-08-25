module Records

  IMPORT_DATE_FORMAT = "%y%m%d"

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def as_cdf_money(hash, key, units=100)
      value = hash[key]
      return 0 if value.nil? || value.to_f == 0
      hash[key] = parse_cdf_money(value, units) if value.to_f > 0
    end
    
    def parse_cdf_money(s, units)
      money = s.to_f / units
      BigDecimal.new(money.to_s, 0)
    end
    
    def as_cdf_date(hash, key)
      value = hash[key]
      return if value.empty?
      hash[key] = parse_cdf_date value if value.to_i > 0
    end

    def parse_cdf_date(s)
      return nil if s.nil?
      Time.strptime(s, IMPORT_DATE_FORMAT)
    end

  end

end
