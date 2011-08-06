module Records
  module Po

# Consumer Bill To Phone Number
    class Po26 < PoBase

      def cdf_record
        cdf = super
        cdf << purchaser_phone_number
        cdf << reserved(26)

        PoBase.ensure_length cdf

      end


      def purchaser_phone_number
        @order.bill_address.phone.ljust_trim 25
      end

    end
  end
end