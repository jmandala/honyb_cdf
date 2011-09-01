class Cdf::OrderBuilder

  SCENARIOS = [
      {:id => 1, :name => 'single order/single line/single quantity'},
      {:id => 2, :name => 'single order/single line/multiple quantity'},
      {:id => 3, :name => 'single order/multiple lines/single quantity'},
      {:id => 4, :name => 'single order/multiple lines/multiple quantity'}
  ]

  def self.new_test
    order = Order.new_test
    order.bill_address = us_address
    order.ship_address = us_address
    order.shipping_method = shipping_method

    order.add_variant Cdf::ProductBuilder.next_in_stock!.master, 1
    payment = order.payments.create(
        :amount => order.total,
        :source => credit_card,
        :payment_method => bogus_payment_method
    )

    complete! order

    # simulate capture
    #payment.complete

    order.update!

    puts order.state


    order
  end

  # Transitions the order to the completed state or raise exception if error occurs while trying
  # @param order [Order]
  def self.complete!(order)
    puts "START: #{order.state}"
    order.update!
    return order if order.complete?
    while !order.complete?
      order.next!
    end
    order
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
