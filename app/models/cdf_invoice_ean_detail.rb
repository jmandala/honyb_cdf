class CdfInvoiceEanDetail < ActiveRecord::Base
  include CdfInvoiceRecord
  include CdfInvoiceDetailRecord
  
  include Records

  belongs_to :cdf_invoice_file

  def self.spec(d)
    d.cdf_invoice_ean_detail do |l|
      l.trap { |line| line[0, 2] == '46' }
      l.template :cdf_invoice_defaults
      l.spacer 6
      l.spacer 20
      l.spacer 20
      l.ean_shipped 14
      l.spacer 5
    end
  end

  def before_populate(data)
    self.ean_shipped = data[:ean_shipped].strip
    data.delete :ean_shipped
  end

end