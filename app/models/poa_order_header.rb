# Purchase Order Header Record
class PoaOrderHeader < ActiveRecord::Base
  include Updateable

  belongs_to :poa_file
  belongs_to :po_status
  belongs_to :order

  has_many :poa_vendor_records, :autosave => true, :dependent => :destroy
  has_one :poa_ship_to_name, :autosave => true, :dependent => :destroy
  has_many :poa_address_lines, :autosave => true, :dependent => :destroy
  has_one :poa_city_state_zip, :autosave => true, :dependent => :destroy
  has_many :poa_line_items, :autosave => true, :dependent => :destroy
  has_many :poa_additional_details, :autosave => true, :dependent => :destroy
  has_many :poa_line_item_title_records, :autosave => true, :dependent => :destroy
  has_many :poa_line_item_pub_records, :autosave => true, :dependent => :destroy
  has_many :poa_item_number_price_records, :autosave => true, :dependent => :destroy

  def self.spec(d)
    d.poa_order_header do |l|
      l.trap { |line| line[0, 2] == '11' }
      l.template :poa_defaults
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

  def self.populate(p, poa_file)
    p[:poa_order_header].each do |data|

      data[:po_status_id] = PoStatus.find_by_code(data[:po_status]).try(:id)

      order = Order.find_by_number(data[:po_number])

      raise ActiveRecord::RecordNotFound.new("No Order found with number: #{data[:po_number]}") if order.nil?

      poa_order_header = self.find_self!(order, poa_file)

      poa_order_header.update_from_hash(data)

    end
  end

  def self.find_self(order, poa_file)
    self.find_by_order_id_and_poa_file_id(order.id, poa_file.id)
  end

  def self.find_self!(order, poa_file)
    object = self.find_self(order, poa_file)
    if object.nil?
      self.create(:order => order, :poa_file => poa_file)
    end
  end
end