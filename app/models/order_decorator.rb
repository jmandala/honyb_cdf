Order.class_eval do

  belongs_to :po_file
  has_many :poa_order_headers, :dependent => :restrict
  has_many :poa_files, :through => :poa_order_headers

  def as_cdf(start_sequence = 1)
    Records::Po::Record.new(self, start_sequence)
  end

  def tax_rate
    TaxRate.match(ship_address).first
  end

  def gift_wrap_fee
    0
  end

  def is_gift?
    false
  end

  def gift_wrap?
    false
  end

  def gift_message
    "Enjoy your gifts!"
  end

  def total_quantity
    line_items.inject(0) { |sum, l| sum + l.quantity }
  end

  def self.needs_po
    where("orders.completed_at IS NOT NULL AND orders.po_file_id IS NULL").order('completed_at asc')
  end

  def self.find_by_po_number!(po_number)
    order = self.find_by_number(po_number)

    raise ActiveRecord::RecordNotFound.new("No Order found with number: #{po_number}") if order.nil?
    
    order
  end


end
