module Records
  module Po
# Line Item Detail
    class Po40 < PoBase
      def cdf_record
        cdf = super
        cdf << line_item_po_number
        cdf << reserved(12)
        cdf << item_number
        cdf << reserved(3)
        cdf << line_level_backorder_code
        cdf << special_action_code
        cdf << reserved("N")
        cdf << item_number_type

        PoBase.ensure_length cdf

      end

      def line_item_po_number
        line_item.id.to_s.ljust_trim 10
      end

      def item_number
        line_item.product.sku.gsub(/-/, '').ljust_trim 20
      end

      def item_number_type
        line_item.product.sku_type.ljust_trim 2
      end

        # N = Do not backorder
        # B = Backorder all items that are not available to ship
        # Blank = use default
      def line_level_backorder_code
        "N"
      end

        # "ID" = item is to be imprinted and signifies that record 45 is present
        # Blank = not applicable
      def special_action_code
        "".ljust_trim 2
      end


    end
  end
end