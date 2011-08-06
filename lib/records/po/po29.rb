module Records
  module Po

# Consumer Bill To City, State, Zipr
    class Po29 < PoBase

      def cdf_record
        cdf = super
        cdf << purchaser_city
        cdf << purchaser_state
        cdf << purchaser_postal_code
        cdf << purchaser_country
        cdf << reserved(9)
        
        PoBase.ensure_length cdf

      end

      def purchaser_city
        @order.bill_address.city.ljust_trim 25
      end

      def purchaser_postal_code
        @order.bill_address.zipcode.ljust_trim 11
      end

      def purchaser_state
        @order.bill_address.state.abbr.ljust_trim(3)
      end

      def purchaser_country
        @order.bill_address.country.iso3
      end
    end
  end
end