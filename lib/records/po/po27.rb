module Records
  module Po

# Consumer Bill To Address Line
    class Po27 < PoBase

      def cdf_record
        cdf = super
        cdf << purchaser_address_line
        cdf << reserved(16)

        PoBase.ensure_length cdf

      end

      def purchaser_address_line
        @order.bill_address.send(address_line).ljust_trim 35
      end

      def address_line
        @options[:address_line] || :address1
      end

    end
  end
end