class Cdf::OrderBuilder

  SCENARIOS = [
      {:id => 1, :name => 'single order/single line/single quantity'},
      {:id => 2, :name => 'single order/single line/multiple quantity', :line_item_qty => 2},
      {:id => 3, :name => 'single order/multiple lines/single quantity', :line_item_count => 2},
      {:id => 4, :name => 'single order/multiple lines/multiple quantity', :line_item_count => 2, :line_item_qty => 2},
      {:id => 5, :name => 'single order/multiple lines/multiple quantity: Hawaii', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :HI},
      {:id => 6, :name => 'single order/multiple lines/multiple quantity: Alaska', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AK},
      {:id => 7, :name => 'single order/multiple lines/multiple quantity: Puerto Rico', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :PR},
      {:id => 8, :name => 'single order/multiple lines/multiple quantity: USVI', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :VI},
      {:id => 9, :name => 'single order/multiple lines/multiple quantity: UM', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :UM},
      {:id => 10, :name => 'single order/multiple lines/multiple quantity: AE', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AE},
      {:id => 11, :name => 'single order/multiple lines/multiple quantity: AA', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AA},
      {:id => 12, :name => 'single order/multiple lines/multiple quantity: AP', :line_item_count => 2, :line_item_qty => 2, :state_abbr => :AP},
      {:id => 13, :name => 'single order/single lines/single quantity: P.O. Box', :address1 => 'P.O. Box 123'},
      {:id => 14, :name => 'Invalid Shipping Method: INTL Priority for Domestic', :state_abbr => :ME, :shipping_method => 'INTL Priority'},
      {:id => 15, :name => 'not yet received EAN', :ean_type => :not_yet_received},
      {:id => 16, :name => 'out of print/osi ean', :ean_type => :out_of_print},
      {:id => 17, :name => 'out of stock ean, backorder cancel', :ean_type => :out_of_stock_backorder_cancel},
      {:id => 18, :name => 'invalid ean', :ean_type => :invalid_ean},
      {:id => 19, :name => 'valid ean, not stocked by Ingram', :ean_type => :valid_not_stocked},
      {:id => 20, :name => 'warehouse shopping override: default', :dc_code => :default},
      {:id => 21, :name => 'warehouse shopping override: Chambersburg, PA', :dc_code => 'C'},
      {:id => 22, :name => 'warehouse shopping override: Fort Wayne, IA', :dc_code => 'D'},
      {:id => 23, :name => 'split shipment: multi shipment', :line_item_qty => 2, :ean_type => :split_ship, :split_shipment_type => :multi_shipment},
      {:id => 24, :name => 'split shipment: release when full', :ean_type => :split_ship, :split_shipment_type => :release_when_full},
      {:id => 25, :name => 'split shipment: dual shipment', :ean_type => :split_ship, :split_shipment_type => :dual_shipment},
      {:id => 26, :name => 'short ship/zero ship 100% of order', :ean_type => :slash_to_zero_ship},
      {:id => 27, :name => 'short ship/slash a single line from a multiple line order', :ean_type => [:slash_by_1, :in_stock]},
      {:id => 28, :name => 'short ship/slash a qty from a multiple line order', :line_item_qty => 4, :ean_type => [:slash_by_1, :in_stock]},
      {:id => 29, :name => 'backorder cancel reported in asn', :ean_type => :out_of_stock_backorder_cancel},
      {:id => 30, :name => 'backorder shipped on product receipt', :ean_type => :out_of_stock_backorder_ship},
      {:id => 31, :name => 'shipping 1 item in multiple boxes from the same DC: in stock', :line_item_qty => 30, :ean_type => :in_stock},
      {:id => 32, :name => 'shipping 1 item in multiple boxes from the same DC', :line_item_qty => 30, :ean_type => :multiple_boxes},      

  ]

  def self.create_for_scenarios(scenarios=[])
    raise ArgumentError, "No scenarios given" if scenarios.empty?

    orders = []
    scenarios.each do |id|
      s = find_scenario id
      puts "create for #{s[:name]} [#{s[:id]}]"
      orders << completed_test_order(s)
    end
    orders
  end

  def self.find_scenario(id)
    SCENARIOS.each do |scenario|
      return scenario if scenario[:id] == id.to_i
    end
    raise ArgumentError, "No scenario found with id: '#{id}'"
  end

  def self.completed_test_order(opts={})
    opts[:state_abbr] ||= :ME
    opts[:line_item_count] ||= 1
    opts[:line_item_qty] ||= 1
    opts[:backordered_line_item_count] ||= 0
    opts[:backordered_line_item_qty] ||= 1
    opts[:dc_code] ||= :default
    opts[:split_shipment_type] ||= :default

    order = Order.new_test
    order.order_name = opts[:name]

    init_dc_code order, opts[:dc_code]
    init_split_shipment_type order, opts[:split_shipment_type]

    address = create_address opts

    order.bill_address = address
    order.ship_address = address

    order.shipping_method = select_shipping_method order, opts

    product_builder = Cdf::ProductBuilder.new

    opts[:line_item_count].times do
      if opts[:ean_type].respond_to?(:each)
        opts[:ean_type].each { |ean_type| order.add_variant product_builder.next_product!(ean_type).master, opts[:line_item_qty] }
      else
        order.add_variant product_builder.next_product!(opts[:ean_type]).master, opts[:line_item_qty]
      end

    end

    order.payments.create(
        :amount => order.total,
        :source => credit_card,
        :payment_method => bogus_payment_method
    )

    # finalize the order
    order.complete!

    # Authorizes all payments
    order.process_payments!

    # Capture payments
    order.capture_payments!
  end

  private

  def self.bogus_payment_method
    Gateway::Bogus.create!(:name => 'Credit Card', :environment => ENV['RAILS_ENV'])
  end

  def self.credit_card
    TestCard.create!(:verification_value => 123, :month => 12, :year => 2013, :number => "4111111111111111")
  end

  def self.select_shipping_method(order, opts={})
    opts[:shipping_method] ||= 'Economy Mail'
    ShippingMethod.find_by_name!(opts[:shipping_method])
  end

  def self.create_address(opts)
    opts[:state_abbr] ||= :ME
    opts[:address1] ||= "10 Lovely Street"
    my_addr = address
    my_addr.address1 = opts[:address1]
    my_addr.state = State.find_by_abbr!(opts[:state_abbr])
    my_addr.country = my_addr.state.country
    my_addr.save!
    my_addr
  end

  def self.address
    Address.new(
        :firstname => 'John',
        :lastname => 'Doe',
        :address1 => '10 Lovely Street',
        :address2 => 'Northwest',
        :city => 'Herndon',
        :zipcode => '20170',
        :phone => '123-4356-7890',
        :alternative_phone => '123-333-9999'
    )
  end

  def self.init_dc_code(order, dc_code)
    order.dc_code = DcCode.find_by_po_dc_code!(dc_code) unless dc_code == :default
  end

  def self.init_split_shipment_type(order, split_shipment_type)
    order.split_shipment_type = Order::SPLIT_SHIPMENT_TYPE[split_shipment_type] unless split_shipment_type == :default
  end
end
