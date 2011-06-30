module Records
  class CdfRecord

    def initialize(order, sequence, args)
      @order = order
      @sequence = sequence
      @options = args
      @options[:name] ||= "undefined"
      @options[:message] ||= ""
    end

    def reserved(arg)
      if arg.is_a? String
        return arg
      end

      sprintf("%#{arg.to_s}s", "")
    end

    def cdf_date(date)
      date.strftime '%y%m%d'
    end

    def sequence_number
      sprintf("%05d", @sequence)
    end

    def cdf_record
      cdf = String.new
      cdf << record_code
      cdf << sequence_number
      cdf << po_number
      cdf
    end


    def po_number
      sprintf("%22d", @order.id)
    end

    def record_code
      @options[:name].gsub(/Po(\d*)/, '\1')
    end

    def to_s
      cdf_record
    end


    def line_item
      @options[:line_item]
    end

  end
end