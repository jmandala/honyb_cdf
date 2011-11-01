puts "PoBoxOption..."
po_box_yes = PoBoxOption.find_or_create_by_name('Yes')
po_box_no = PoBoxOption.find_or_create_by_name('No')
po_box_depends = PoBoxOption.find_or_create_by_name('Dependant on ship-to country')

puts "AddressType..."
intl = AddressType.find_or_create_by_code('intl', :name => 'International')
domestic = AddressType.find_or_create_by_code('us', :name => 'Domestic')

puts "AsnShippingMethodCode..."
two_day_air = AsnShippingMethodCode.find_or_create_by_code('12',
                                             :address_type => 'Domestic',
                                             :name => '2nd Day Air',
                                             :big_bisac_code_sent_in => '### 2ND DAY AIR',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('17',
                                             :address_type => 'Domestic',
                                             :name => '3 Day Select',
                                             :big_bisac_code_sent_in => '### 3 DAY SELECT',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('10',
                                             :address_type => 'Domestic',
                                             :name => 'Ground',
                                             :big_bisac_code_sent_in => '### UPS',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('11',
                                             :address_type => 'Domestic',
                                             :name => 'Next Day Air',
                                             :big_bisac_code_sent_in => '### NEXT DAY AIR',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('1A',
                                             :address_type => 'Domestic',
                                             :name => 'Next Day Air Saver',
                                             :big_bisac_code_sent_in => '### NEXT DAY AIR SAVER',
                                             :po_box_option_id => po_box_no.id)

economy_mail = AsnShippingMethodCode.find_or_create_by_code('21',
                                                            :address_type => 'Domestic',
                                                            :name => 'Economy Mail',
                                                            :big_bisac_code_sent_in => '### USA ECONOMY',
                                                            :po_box_option_id => po_box_yes.id)

expedited_mail = AsnShippingMethodCode.find_or_create_by_code('24',
                                                              :address_type => 'Domestic',
                                                              :name => 'Expedited Mail',
                                                              :big_bisac_code_sent_in => '### USA EXPEDITED',
                                                              :po_box_option_id => po_box_yes.id)

AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL COURIER',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :name => 'INTL Courier (trackable) **',
                                                               :po_box_option_id => po_box_depends.id,
                                                               :notes => 'not available in Puerto Rico')

intl_priority = AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL PRIORITY',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :name => 'INTL Priority (non-trackable)',
                                                               :big_bisac_code_sent_in => '',
                                                               :po_box_option_id => po_box_yes.id)

AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL W/DEL CONFIRMATION',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :name => 'INTL with Delivery Confirmation ** *',
                                                               :big_bisac_code_sent_in => '',
                                                               :po_box_option_id => po_box_depends.id,
                                                               :notes => 'only available for Canada, Great Britain, and Japan')

invalid_asn = AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INVALID_TEST',
                                                               :code => 'XX',
                                                               :address_type => 'Domestic',
                                                               :name => 'INVALID SHIPPING METHOD',
                                                               :big_bisac_code_sent_in => '',
                                                               :po_box_option_id => po_box_depends.id,
                                                               :notes => 'INVALID -- ONLY USE FOR TESTING')

methods = [
    {:name => 'Economy Mail', :first_item => 3.99, :additional_item => 0.99, :asn_shipping_method_code => economy_mail},
    {:name => 'Expedited Mail', :first_item => 4.98, :additional_item => 1.99, :asn_shipping_method_code => expedited_mail},
    {:name => '2nd Day Air', :first_item => 19.98, :additional_item => 5.99, :asn_shipping_method_code => two_day_air},
    {:name => 'INTL Priority', :first_item => 19.98, :additional_item => 5.99, :asn_shipping_method_code => intl_priority, :zone => Zone.intl, :environment => 'development,test'},
    {:name => 'Invalid Shipping Method', :first_item => 3.99, :additional_item => 0.99, :asn_shipping_method_code => invalid_asn, :environment => 'development,test'},
]

puts "ShippingMethods..."
methods.each do |options|
  name = options[:name]
  puts "\t#{name}"
  asn_shipping_method = options[:asn_shipping_method_code]
  asn_shipping_method.to_yaml
  shipping_method = ShippingMethod.find_by_name(name)
  options[:zone] ||= Zone.all_us
  unless shipping_method
    shipping_method = ShippingMethod.create(:name => name, :zone => options[:zone], :calculator_type => 'Calculator::AdvancedFlexiRate', :environment => options[:environment])
    shipping_method.calculator.preferred_first_item = options[:first_item]
    shipping_method.calculator.preferred_additional_item = options[:additional_item]
    shipping_method.save!
    asn_shipping_method.shipping_method = shipping_method
    asn_shipping_method.save!
    puts "\t Created '#{name}' with #{shipping_method.calculator.preferred_first_item.to_s} for the first item and #{shipping_method.calculator.preferred_additional_item.to_s} for each additional item"
  end
end

