class CdfInvoiceHeader < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file

  def self.spec(d)
    d.cdf_invoice_header do |l|
      l.trap { |line| line[0, 2] == '15' }
      l.template :cdf_invoice_defaults
      l.spacer 19
      l.company_account_id_number 7
      l.spacer 5
      l.warehouse_san 7
      l.spacer 3
      l.invoice_date 8
      l.spacer 16
    end
  end

end