class CdfInvoiceIsbnDetail < ActiveRecord::Base
  include CdfInvoiceRecord
  include Records

  belongs_to :cdf_invoice_file

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
  
  def self.find_nearest(cdf_invoice_file, sequence_number)
        where(:cdf_invoice_file_id => cdf_invoice_file.id).
        where("sequence_number < :sequence_number", {:sequence_number => sequence_number}).
        order("sequence_number DESC").
        limit(1).first
  end
  

end