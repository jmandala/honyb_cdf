class CdfInvoiceFileTrailer < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file

  def self.spec(d)
    d.cdf_invoice_file_trailer do |l|
      l.trap { |line| line[0, 2] == '95' }
      l.record_code 2
      l.total_titles 13
      l.total_invoices 5
      l.total_units 10
      l.spacer 45
    end
  end

end