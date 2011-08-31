Order.class_eval do

  before_create :init_order_type
  
  TYPES = [:live, :test]
  
  belongs_to :po_file
  has_many :poa_order_headers, :dependent => :restrict
  has_many :poa_files, :through => :poa_order_headers
  has_many :asn_shipments, :dependent => :restrict
  has_many :asn_shipment_details, :dependent => :restrict
  has_many :asn_files, :through => :asn_shipments
  has_many :cdf_invoice_detail_totals, :dependent => :restrict
  has_many :cdf_invoice_freight_and_fees, :dependent => :restrict
  

  register_update_hook :update_auth_before_ship
  
  def update_auth_before_ship
    # todo: update authorized_total
  end

  def as_cdf(start_sequence = 2)
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
    where("orders.completed_at IS NOT NULL").
        where("orders.po_file_id IS NULL").
        where("orders.shipment_state = 'ready'").
        order('completed_at asc')
  end
  
  def self.test
    where(:order_type => :test)
  end
  

  # Creates a new test order
  def self.new_test
    order = Order.new
    order.order_type = :test
    order
  end
  
  # Returns true if this order is a test order
  def test?
    self.order_type == :test
  end
  
  # Returns true if this order is a live order
  def live?
    !test?
  end
  
  # Changes into a test order
  # Throws exception if order is already complete
  def to_test
    raise Cdf::IllegalStateError, "Cannot convert Order [#{self.number}] to test because it has been completed." if self.completed?
    self.order_type = :test
    self
  end
  
  private
  # Sets the order type if not already set 
  def init_order_type
    self.order_type = :live if self.order_type.nil?
  end
  
end
