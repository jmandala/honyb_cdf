# Purchase Order Header Record
class PoaOrderHeader < ActiveRecord::Base
  include Updateable

  belongs_to :poa_file
  belongs_to :po_file
  belongs_to :po_status

  def self.spec(d)
    d.poa_order_header do |l|
      l.trap { |line| line[0, 2] == '11' }
      l.template :boundary
      l.toc 13
      l.po_number 22
      l.icg_ship_to_account_number 7
      l.icg_san 7
      l.po_status 1
      l.acknowledgement_date 6
      l.po_date 6
      l.po_cancellation_date 6
      l.spacer 5
    end
  end

  def self.populate(p)
    p[:poa_order_header].each do |data|
      order = Order.find_by_number(data[:po_number])

      if order.nil?
        raise ActiveRecord::RecordNotFound.new("No Order found with number: #{data[:po_number]}")
      end

      if order.po_file.nil?
        raise ActiveRecord::RecordNotFound.new("No PO File found for order number: #{data[:po_number]}")
      end

      po_file = order.po_file

      poa_order_header = PoaOrderHeader.find_or_create_by_po_file_id_and_poa_file_id(po_file.id, id)

      data[:po_status_id] = PoStatus.find_by_code(data[:po_status]).try(:id)

      poa_order_header.update_from_hash(data)
    end
  end
end