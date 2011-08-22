class CdfInvoiceDetailTotal < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records


  belongs_to :cdf_invioce_file
  belongs_to :order

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
    order = Order.find_by_number(data[:client_order_id])
    data[:order_id] = order.id unless order.nil?

    line_item = LineItem.find_by_id(data[:line_item_id_number])
    data[:line_item_id] = line_item.id unless line_item.nil?
  end
end
