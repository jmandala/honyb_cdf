module Records
# Recipient Address Line
  class Po32 < CdfRecord

    def cdf_record
      cdf = super
      cdf << recipient_address_line
      cdf << reserved(16)
    end

    def recipient_address_line
      @order.ship_address.send(address_line).ljust_trim 35
    end

    def address_line
      @options[:address_line] || :address1
    end

  end
end