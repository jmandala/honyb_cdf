module Records
  module Po


# Consumer Bill To Phone Number
    class Po31 < PoBase

      def cdf_record
        cdf = super
        cdf << recipient_phone_number
        cdf << reserved(26)

        PoBase.ensure_length cdf
        
      end

      def recipient_phone_number
        @order.ship_address.phone.ljust_trim 25
      end

    end
  end
end