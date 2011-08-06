module Records
  module Po

# Recipient Cost
    class Po24 < PoBase

      def cdf_record
        cdf = super
        cdf << sales_tax_percent
        cdf << freight_tax_percent
        cdf << freight_amount
        cdf << reserved(28)

        PoBase.ensure_length cdf

      end


      def sales_tax_percent
        if @order.tax_rate
          return sprintf("%08d", @order.tax_rate.amount)
        end

        sprintf("%08.4f", 0)
      end

      def freight_tax_percent
        sprintf("%07.4f", 0)
      end

      def freight_amount
        sprintf("%08.2f", @order.ship_total)
      end

    end
  end
end