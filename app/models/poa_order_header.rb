# Purchase Order Header Record
class PoaOrderHeader < ActiveRecord::Base
  include Updateable
  include Records

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
  has_one :poa_order_control_total, :autosave => true, :dependent => :destroy

  delegate :number, :to => :order, :prefix => true


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
      order = Order.find_by_number!(data[:po_number].strip!)
      object = find_self!(order, poa_file)
      [:acknowledgement_date, :po_cancellation_date, :po_date].each do |key|
        as_cdf_date data, key
      end
      object.update_from_hash(data)
      object.po_status = PoStatus.find_by_code!(data[:po_status])
      object.save!
    end
  end

  def self.find_self(order, poa_file)
    where(:order_id => order, :poa_file_id => poa_file).first
  end

  def self.find_self!(order, poa_file)
    object = find_self(order, poa_file)
    return object unless object.nil?
    create(:order => order, :poa_file => poa_file)
  end

  def vendor_message()
    message = ""
    self.poa_vendor_records.each { |v| message << v.vendor_message }
    message.gsub(/\s+/, ' ')
  end
end