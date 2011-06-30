module Records
  module Po

    class PoBase < Records::Base

      def initialize(order, sequence, args)
        super(sequence, args)
        @order = order
      end

      def cdf_record
        cdf = super
        cdf << po_number
      end

      def po_number
        sprintf("%22d", @order.id)
      end

      def line_item
        @options[:line_item]
      end

    end
  end
end