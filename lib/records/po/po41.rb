module Records
  module Po
# Additional Line Item Detail
    class Po41 < PoBase
      def cdf_record
        cdf = super
        cdf << client_item_list_price
        cdf << line_level_backorder_cancel_date
        cdf << line_level_gift_wrap_code
        cdf << order_quantity
        cdf << clients_proprietary_item_number
        cdf << reserved(7)

        PoBase.ensure_length cdf

      end

        # The list price or discounted price to the consumer used to recalculate
        # product charges for each Order. It is printed on the Packing Slip and is
        # required for International shipping. Right justify, zero fill. Explicit
        # (required) decimal, max 2 decimal places to the right of the decimal.
        # Example:@"00012.75"
      def client_item_list_price
        sprintf("%08.2f", line_item.price)
      end

      def line_level_backorder_cancel_date
        cdf_date(line_item.created_at + Cdf::Config[:days_to_hold_backorder])
      end

      def line_level_gift_wrap_code
        line_item.gift_wrap? ? "022" : reserved(3)
      end

      def order_quantity
        sprintf("%07d", line_item.quantity)
      end

      def clients_proprietary_item_number
        line_item.product.id.to_s.ljust_trim 20
      end

    end
  end
end