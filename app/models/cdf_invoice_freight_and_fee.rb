class CdfInvoiceFreightAndFee < ActiveRecord::Base
  include Updateable
  extend CdfInvoiceRecord

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

  end

end