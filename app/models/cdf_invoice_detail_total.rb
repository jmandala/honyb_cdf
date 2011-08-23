class CdfInvoiceDetailTotal < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file
  belongs_to :cdf_invoice_isbn_detail
  belongs_to :cdf_invoice_ean_detail
  belongs_to :order
  belongs_to :line_item

  def self.spec(d)
    d.cdf_invoice_detail_total do |l|
      l.trap { |line| line[0, 2] == '48' }
      l.template :cdf_invoice_defaults
      l.spacer 8
      l.title 16
      l.spacer 5
      l.client_order_id 22
      l.line_item_id_number 10
      l.spacer 4
    end
  end

  def before_populate(data)

    self.order = Order.find_by_number!(data[:client_order_id].strip)
    data.delete :client_order_id

    self.line_item = LineItem.find_by_id!(data[:line_item_id_number].strip)
    data.delete :line_item_id_number
    
    self.cdf_invoice_isbn_detail = CdfInvoiceIsbnDetail.find_nearest!(self.cdf_invoice_file, data[:sequence_number])
  end
end
