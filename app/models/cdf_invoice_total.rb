class CdfInvoiceTotal < ActiveRecord::Base
  include CdfInvoiceDetailRecord
  include Records

  def self.spec(d)
    d.cdf_invoice_total do |l|
      l.trap { |line| line[0, 2] == '55' }
      l.template :cdf_invoice_defaults
      l.spacer 5
      l.invoice_record_count 5
      l.number_of_titles 5
      l.total_number_of_units 6
      l.bill_of_lading_number 10
      l.spacer 7
      l.total_invoice_weight 7
      l.spacer 20
    end
  end

  def before_populate(data)

  end

end
