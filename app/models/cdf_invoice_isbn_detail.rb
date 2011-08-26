class CdfInvoiceIsbnDetail < ActiveRecord::Base
  include CdfInvoiceDetailRecord
  include Records

  has_one :cdf_invoice_detail_total
    
  def self.spec(d)
    d.cdf_invoice_isbn_detail do |l|
      l.trap { |line| line[0, 2] == '45' }
      l.template :cdf_invoice_defaults
      l.spacer 6
      l.spacer 13
      l.isbn_10_shipped 10
      l.spacer 1
      l.quantity_shipped 5
      l.ingram_list_price 7
      l.spacer 1
      l.discount 4
      l.spacer 1
      l.net_price 8
      l.metered_date 8
      l.spacer 1
    end
  end

  def before_populate(data)
    [:net_price,
     :ingram_list_price,
     :discount].each do |key|
      self.send("#{key}=", self.class.as_cdf_money(data, key))
      data.delete key
    end
  end

end