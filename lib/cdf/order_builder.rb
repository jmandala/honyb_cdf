class Cdf::OrderBuilder

  SCENARIOS = [
      {:id => 1, :name => 'single order/single line/single quantity'},
      {:id => 2, :name => 'single order/single line/multiple quantity', :line_item_qty => 2},
      {:id => 3, :name => 'single order/multiple lines/single quantity', :line_item_count => 2},
      {:id => 4, :name => 'single order/multiple lines/multiple quantity', :line_item_count => 2, :line_item_qty => 2}
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
    opts[:ship_location] ||= :domestic
    opts[:line_item_count] ||= 1
    opts[:line_item_qty] ||= 1
    opts[:backordered_line_item_count] ||= 0
    opts[:backordered_line_item_qty] ||= 1

    order = Order.new_test

    if opts[:ship_location] == :domestic
      address = us_address
    else
      address = foreign_address
    end

    order.bill_address = address
    order.ship_address = address
    order.shipping_method = shipping_method

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


  def self.create_zone
    zone = Zone.new(:name => 'GlobalZone')
    Country.all.map { |c| ZoneMember.create!(:zoneable => c, :zone => zone) }
    zone.save!
    zone
  end

  def self.shipping_method
    zone = Zone.find_by_name('GlobalZone') || create_zone

    sm = ShippingMethod.new(:name => 'UPS Ground', :zone => zone)
    calculator = Calculator::FlatRate.new(:calculable => sm, :calculable_type => 'ShippingMethod')
    calculator.set_preference(:amount, 10.0)
    sm.calculator = calculator
    sm.save!
    sm
  end

  def self.us_address
    my_addr = address
    my_addr.state = maine
    my_addr.country = usa
    my_addr.save!
    my_addr
  end

  def self.foreign_address
    raise Cdf::IllegalStateError, "Foreign address not supported!"
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

  def self.maine
    State.find_by_abbr('ME') || State.create!(:name => 'MAINE', :abbr => 'ME', :country => usa)
  end

  def self.usa
    Country.find_by_iso3('USA') || Country.create!(:iso_name => 'UNITED STATES', :name => 'UNITED STATES', :iso => 'US', :iso3 => 'USA', :numcode => 840)
  end

end
