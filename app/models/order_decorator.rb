Order.class_eval do

  has_many :children, :class_name => Order.name, :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => Order.name, :foreign_key => 'parent_id'
  
  
  before_create :init_order


  ORDER_NAME = 'Order Name'

  TYPES = [:live, :test]

  # EL = Multi-shipment: Allow immediate shipment of all in-stockt itles
  # for every warehouse shopped. Backorders will allocate AND SHIP as stock
  # becomes available. On the cancel date unallocated lines will be cancelled.
  # This order type can create many shipments from any Ingram facility. This
  # order type provides fastest deliverly of the product to the consumer.
  #
  # RF = Release when full: This order type will allow allocation of stock to take place
  # when the original PO was entered. When all lines on the PO have allocated the PO will ship.
  # On the cancel date any unallocated lines will be cancelled, all allocated product will ship.
  # This order will result in one shipment per warehouse. This order type provides lowest freight
  # charges to the consumer.
  #
  # LS = Dual Shipment:This order type will allow immediate shipment of all in-stock titles for
  # every warehouse shopped. Backorders will allocate as stock becomes available. When there are no
  # more backorders the order will ship. On the cancel date the unallocated lines will be cancelled, all
  # allocated product will ship. This order type will result in up to two shipments per warehouse
  SPLIT_SHIPMENT_TYPE = {
      :multi_shipment => 'EL',
      :release_when_full => 'RF',
      :dual_shipment => 'LS'
  }

  belongs_to :po_file
  belongs_to :dc_code
  has_many :poa_order_headers, :dependent => :restrict
  has_many :poa_files, :through => :poa_order_headers
  has_many :asn_shipments, :dependent => :restrict
  has_many :asn_shipment_details, :dependent => :restrict
  has_many :asn_files, :through => :asn_shipments
  has_many :cdf_invoice_detail_totals, :dependent => :restrict
  has_many :cdf_invoice_freight_and_fees, :dependent => :restrict
  has_many :cdf_invoice_headers, :through => :cdf_invoice_detail_totals

  register_update_hook :update_auth_before_ship

  def cdf_invoice_files
    result = []
    self.cdf_invoice_headers.each do |h|
      result << h.cdf_invoice_file unless result.include? h.cdf_invoice_file
    end
    result
  end

  def cdf_invoice_total
    self.cdf_invoice_freight_and_fees.sum(:amount_due)
  end

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
    ""
  end

  def total_quantity
    line_items.inject(0) { |sum, l| sum + l.quantity }
  end

  def self.needs_po
    where("orders.completed_at IS NOT NULL").
        where("orders.po_file_id IS NULL").
        where("orders.shipment_state = 'ready'").
        order('orders.completed_at asc')
  end

  def needs_po?
    self.complete? && !self.has_po? && self.shipment_state == 'ready'
  end

  def ready_for_po?
    !self.has_po? && self.complete? && self.shipment_state == 'ready'
  end

  def po_requirements
    return [] if ready_for_po?
    requires = []
    requires << 'not complete!' if !self.complete?
    requires << "shipment state is, '#{self.shipment_state}', should be 'ready'." if self.shipment_state != 'ready'
    requires
  end

  def has_po?
    !self.po_file.nil?
  end

  def self.test
    where(:order_type => :test)
  end


  # Creates a new test order
  def self.new_test
    order = Order.new
    order.order_type = :test
    order.user = User.compliance_tester!
    order.save!
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

  # Transitions order to the next state and throws exception if it fails
  #def next!
  #  if !self.next
  #    raise Cdf::IllegalStateError, "Cannot transition order because: #{self.errors.to_yaml}"
  #  end
  #end

  # Transitions the order to the completed state or raise exception if error occurs while trying  
  def complete!
    self.update!
    return self if self.complete?
    while !self.complete?
      self.next!
    end
    self.update!
    self
  end

  # Capture all authorizations
  # This is a dangerous method to run willy-nilly. Be sure you know what you are doing!
  def capture_payments!
    self.payments.each do |p|
      p.source.capture p
    end
    self.payments.reload
    self.update!
    self
  end

  # Creates a new comment with type 'Order Name'
  def order_name=(name)
    order_name_type = CommentType.find_by_name!(ORDER_NAME)
    self.comments.create(:comment => name, :comment_type => order_name_type, :commentable => self, :commentable_type => self.class.name, :user => User.current)
  end

  def order_name
    if self.comments.count == 0
      return ''
    end
    comment = self.comments.find_by_comment_type_id(CommentType.find_by_name(ORDER_NAME))
    if comment.nil?
      return ''
    end

    comment.comment
  end

  # Creates a new Order based on this one, copying
  # * bill_address
  # * ship_address
  # * line_items
  # * shipping_method
  def duplicate
    dup = Order.new
    dup.parent = self
    self.children << dup

    [:email,
     :ship_address,
     :bill_address,
     :shipping_method,
     :special_instructions,
     :split_shipment_type,
     :dc_code,
     :order_type].each do |attr|
      value = self.send(attr)
      dup.send("#{attr.to_s}=", value)
    end

    # assign line_items
    self.line_items.each { |li| dup.add_variant li.variant, li.quantity }

    # set name
    dup.order_name = "Duplicate of #{self.number}: #{self.order_name}"
    dup.save!
    dup
  end

  private
  # Sets the order type if not already set 
  def init_order
    self.order_type = :live if self.order_type.nil?
    self.dc_code = DcCode.default if self.dc_code.nil?
    self.split_shipment_type = SPLIT_SHIPMENT_TYPE[Cdf::Config[:split_shipment_type].to_sym] if self.split_shipment_type.nil?
  end

end
