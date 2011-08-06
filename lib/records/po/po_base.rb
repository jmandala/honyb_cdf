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
        @order.number.ljust_trim 22
      end

      def line_item
        @options[:line_item]
      end

      def self.ensure_length(cdf)
        raise StandardError.new("Invalid Line Length '#{cdf.to_s.length}': #{cdf.to_s}") if cdf.to_s.length % 80 > 0
        cdf
      end


    end
  end
end