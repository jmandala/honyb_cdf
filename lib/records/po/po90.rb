module Records
  module Po
# Client Header
    class Po90 < Records::Base

      def cdf_record
        cdf = super
        cdf << total_line_items
        cdf << total_purchase_orders
        cdf << total_units_ordered
        for i in 0..8 do
          cdf << count_format(i.to_s)
        end

        PoBase.ensure_length cdf
      end

      def total_line_items
        sprintf "%013d", count[:total_line_items]
      end

      def total_purchase_orders
        count_format :total_purchase_orders
      end

      def total_units_ordered
        sprintf "%010d", count[:total_units]
      end

      private
      def count
        @options[:count]
      end

      def count_format(sym)
        sprintf "%05d", count[sym]
      end
    end

  end
end