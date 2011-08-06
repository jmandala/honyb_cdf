module Records
  module Po

# Recipient Ship To Name
    class Po30 < PoBase

      def cdf_record
        cdf = super
        cdf << recipient_name
        cdf << reserved(15)
        cdf << address_validation

        PoBase.ensure_length cdf
        
      end

        # Allow Ingram to validate and scrub address information
        # Y = yes
        # N = no
        # Blank to use default
      def address_validation
        "Y"
      end

      def recipient_name
        "#{@order.ship_address.firstname} #{@order.ship_address.lastname}".ljust_trim 35
      end

    end
  end
end