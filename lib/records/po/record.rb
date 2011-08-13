module Records
  module Po
    class Record < Records::Base
      attr_reader :count

      def initialize(order, start_sequence)
        @order = order
        init_counters start_sequence
      end

      def append(clazz, args = {})
        args[:name] = clazz.name
        record = clazz.send(:new, @order, @count[:sequence], args)
        update_counters_for record
        data = record.cdf_record
        return '' if data.nil?
        data + LINE_TERMINATOR
      end

      def to_s
        cdf = StringIO.new
        cdf << append(Po10)
        cdf << append(Po20)
        cdf << append(Po21)
        cdf << append(Po24)
        cdf << append(Po25)
        cdf << append(Po26)
        cdf << append(Po27)
        cdf << append(Po27, :address_line => :address2)
        cdf << append(Po29)
        cdf << append(Po30)
        cdf << append(Po31)
        cdf << append(Po32)
        cdf << append(Po32, :address_line => :address2)
        cdf << append(Po34)
        cdf << append(Po35)
        cdf << append(Po37, :message => marketing_message)

        if @order.gift_message
          cdf << append(Po38, :message => @order.gift_message)
        end

        @order.line_items.each do |line_item|
          cdf << append(Po40, :line_item => line_item)
          cdf << append(Po41, :line_item => line_item)
          if line_item.gift_message
            cdf << append(Po42, :line_item => line_item, :message => line_item.gift_message)
          end
        end

        cdf << append(Po50, :record_count => @count[:total]+1)

        cdf.string
      end

      def marketing_message
        "HonyB Books"
      end

      private

      def init_counters(start)
        @count = {}
        @count[:sequence] = start
        @count[:total] = 0
        for i in 0..8 do
          @count[i.to_s] = 0
        end
      end

      def update_counters_for(record)
        @count[:sequence] += 1
        @count[:total] += 1
        @count[record.record_code[0].to_s] += 1
      end


    end
  end
end