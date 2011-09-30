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

    order = Order.new_test

    address = create_address opts

    order.bill_address = address
    order.ship_address = address

    order.shipping_method = select_shipping_method order

    product_builder = Cdf::ProductBuilder.new

    opts[:line_item_count].times do
      order.add_variant product_builder.next_in_stock!.master, opts[:line_item_qty]
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

  def self.select_shipping_method(order)
    all_methods = ShippingMethod.all_available order
    raise Cdf::IllegalStateError, "No valid shipping methods for order: #{order.ship_address.state.abbr}, #{order.ship_address.country.iso3}" if all_methods.empty?
    all_methods.first
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
end
