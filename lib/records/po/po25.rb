module Records
  module Po

# Consumer Bill To Name
    class Po25 < PoBase

      def cdf_record
        cdf = super
        cdf << purchasing_consumer_name
        cdf << reserved(16)

        PoBase.ensure_length cdf

      end


      def purchasing_consumer_name
        "#{@order.bill_address.firstname} #{@order.bill_address.lastname}".ljust_trim 35
      end

    end
  end
end