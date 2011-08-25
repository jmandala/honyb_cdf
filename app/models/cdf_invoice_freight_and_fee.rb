class CdfInvoiceFreightAndFee < ActiveRecord::Base
  include CdfInvoiceRecord
  include CdfInvoiceDetailRecord

  include Records

  belongs_to :cdf_invoice_file

  def self.spec(d)
    d.cdf_invoice_freight_fee do |l|
      l.trap { |line| line[0, 2] == '49' }
      l.template :cdf_invoice_defaults
      l.tracking_number 25
      l.net_price 8
      l.shipping 6
      l.handling 7
      l.gift_wrap 6
      l.spacer 6
      l.amount_due 7
    end
  end

  def before_populate(data)
    [:net_price,
     :shipping,
     :handling,
     :gift_wrap,
     :amount_due].each do |key|
      self.send("#{key}=", self.class.as_cdf_money(data, key))
      data.delete key
    end

  end

end