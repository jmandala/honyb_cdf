module Records
  module Po

# Purchase Order Control
    class Po50 < PoBase
      def cdf_record
        cdf = super
        cdf << total_purchase_order_records
        cdf << total_line_items
        cdf << total_units_ordered
        cdf << reserved(26)

        PoBase.ensure_length cdf

      end

      def total_purchase_order_records
        sprintf("%05d", @options[:record_count])
      end

      def total_line_items
        sprintf "%010d", @order.line_items.count
      end

      def total_units_ordered
        sprintf("%010d", @order.total_quantity)
      end
    end
  end
end