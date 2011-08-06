module Records
  module Po
# Drop Ship Detail
    class Po35 < PoBase

      def cdf_record
        cdf = super
        cdf << reserved(8)
        cdf << gift_wrap_fee
        cdf << send_consumer_email
        cdf << order_level_gift_indicator
        cdf << suppress_price_indicator
        cdf << order_level_gift_wrap
        cdf << reserved(30)

        PoBase.ensure_length cdf

      end

      def gift_wrap_fee
        sprintf("%07.2f", @order.gift_wrap_fee)
      end

      def send_consumer_email
        "N"
      end

        # "Y" or "N" -- denotes if order is a gift.
        # The title on the packing slip will be replaced with
        # "A Gift For You" and all Pricing will be suppressed
        # (unless required for shipment). If the order is to
        # be gift wrapped, use in conjunction with the order
        # level gift wrap code
      def order_level_gift_indicator
        @order.is_gift? ? "Y" : "N"
      end

      def suppress_price_indicator
        "N"
      end

      def order_level_gift_wrap
        @order.gift_wrap? ? "022" : reserved(3)
      end
    end
  end
end