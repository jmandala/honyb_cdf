module Records

  class Base

    # The character sequence between records -- defined by Ingram
    LINE_TERMINATOR = "\r\n"

    def initialize(sequence, args = {})
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
    end

    def record_code
      @options[:name].gsub(/.+?(\d*)/, '\1')
    end

    def to_s
      cdf_record
    end

  end

end