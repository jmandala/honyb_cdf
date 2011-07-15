class CdfInvoiceEanDetail < ActiveRecord::Base
  include Updateable
  extend CdfInvoiceRecord

  belongs_to :cdf_invoice_file

  def self.spec(d)
    d.cdf_invoice_ean_detail do |l|
      l.trap { |line| line[0, 2] == '46' }
      l.template :cdf_invoice_defaults
      l.spacer 6
      l.spacer 20
      l.spacer 20
      l.spacer 1
      l.ean 14
      l.spacer 5
    end
  end

  def before_populate(data)

  end

end