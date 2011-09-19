class CdfInvoiceHeader < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file
  has_many :orders, :through => :cdf_invoice_detail_totals
  has_many :cdf_invoice_detail_totals, :dependent => :destroy
  has_many :cdf_invoice_freight_and_fees, :dependent => :destroy
  has_one :cdf_invoice_trailer, :dependent => :destroy

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

  def before_populate(data)
    if data[:warehouse_san].empty?
      self.warehouse_san = 0
      data.delete :warehouse_san
    end
  end
end