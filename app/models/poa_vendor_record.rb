class PoaVendorRecord< ActiveRecord::Base
  include Updateable

  belongs_to :poa_order_header

  def self.spec(d)
    d.poa_vendor_record do |l|
      l.trap { |line| line[0, 2] == '21' }
      l.template :poa_defaults_plus
      l.vendor_message 50
      l.spacer 1
    end
  end

  def self.populate(p, poa_file)
    p[:poa_vendor_record].each do |data|

      # Get the poa_order_header for this record
      # order
      # poa_file

      order = Order.find_by_number(data[:po_number])

      if order.nil?
        raise ActiveRecord::RecordNotFound.new("No Order found with number: #{data[:po_number]}")
      end


      poa_order_header = PoaOrderHeader.find_self(order, poa_file)

      poa_vendor_record = self.find_self!(poa_order_header, data[:sequence_number])

      data[:poa_order_header_id] = poa_order_header.id

      poa_vendor_record.update_from_hash(data)
    end
  end

  def self.find_self(poa_order_header, sequence_number)
    self.where(:poa_order_header_id => poa_order_header, :sequence_number => sequence_number).first
  end

  def self.find_self!(poa_order_header, sequence_number)
    poa_vendor_record = self.find_self(poa_order_header, sequence_number)

    if poa_vendor_record.nil?
      self.create(:poa_order_header => poa_order_header, :sequence_number => sequence_number)
    end
  end

end
