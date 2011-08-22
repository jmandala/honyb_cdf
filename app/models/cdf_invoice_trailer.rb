class CdfInvoiceTrailer < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file

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

end