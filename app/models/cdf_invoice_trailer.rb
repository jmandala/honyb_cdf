class CdfInvoiceTrailer < ActiveRecord::Base
  include CdfInvoiceDetailRecord
  include Records

  belongs_to :cdf_invoice_header
  
  def self.spec(d)
    d.cdf_invoice_trailer do |l|
      l.trap { |line| line[0, 2] == '57' }
      l.template :cdf_invoice_defaults
      l.spacer 5
      l.total_net_price 9
      l.spacer 6
      l.total_shipping 7
      l.total_handling 7
      l.total_gift_wrap 6
      l.spacer 6
      l.spacer 10
      l.total_invoice 9
    end
  end

  def before_populate(data)
    [:total_invoice,
     :total_gift_wrap,
     :total_handling,
     :total_shipping,
     :total_net_price
    ].each do |key|
      self.send("#{key}=", self.class.as_cdf_money(data, key))
      data.delete key
      
    end
    self.cdf_invoice_header = CdfInvoiceHeader.find_by_invoice_number!(data[:invoice_number].strip)

  end
end