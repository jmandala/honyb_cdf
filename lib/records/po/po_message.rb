module Records
  module Po
    class PoMessage < PoBase
      def cdf_record
        cdf = super
        cdf << message

        PoBase.ensure_length cdf

      end

      def message
        @options[:message].ljust_trim 51
      end
    end
  end
end