require 'csv'

### Create PO Types ###
PoType.find_or_create_by_code(0,
                              :name => 'Purchase Order',
                              :description => "Process all PO's for fulfillment"
)
PoType.find_or_create_by_code(1,
                              :name => 'Request Confirmation (POA)',
                              :description => "Ingram will return the oldest unconfirmed POA. See specification for further details."
)
PoType.find_or_create_by_code(2, :name => 'Reserved for future use')
PoType.find_or_create_by_code(3,
                              :name => 'Stock Status Request',
                              :description => "Check Ingram inventory levels without fulfillment (placing an order). The POA provides DCInventory Information. The PO is canceled, no inventory is allocated, and nothing is shipped."
)
PoType.find_or_create_by_code(4, :name => 'Reserved for future use')
PoType.find_or_create_by_code(5,
                              :name => 'Specific Confirmation',
                              :description => "Ingram will return the POA for a specific PO based on your order placement method. See specification for further details."
)
PoType.find_or_create_by_code(7,
                              :name => 'Request Confirmation',
                              :description => "Ingram will return the oldest unconfirmed POA. See specification for further details. **This PO Type is only available to Clients submitting their orders via a webservice."
)
PoType.find_or_create_by_code(8,
                              :name => 'Test Purchase Order',
                              :description => "Should a client need to do some testing with our systems after they begin sending live orders, a PO Type 8 will allow them to receive test POA's, ASN's, and INV's without fulfillment of the order. POType 8 orders will be canceled. No inventory will be allocated and nothing will be shipped."
)

PoaType.find_or_create_by_code(1, :description => 'Full Acknowledgement - all records')
PoaType.find_or_create_by_code(2, :description => 'no 42 and 43 records')
PoaType.find_or_create_by_code(3, :description => 'no 44 records')
PoaType.find_or_create_by_code(4, :description => 'no 42, 43 or 44 records')
PoaType.find_or_create_by_code(5, :description => 'Exception Acknowledgement - report only the lines where an exception has occurred')


CSV.foreach(CdfConfig::po_status_file) do |row|
  PoStatus.find_or_create_by_code(row[0], :name => row[1])
end

CSV.foreach(CdfConfig::poa_status_file) do |row|
  PoaStatus.find_or_create_by_code(row[0], :name => row[1])
end

CSV.foreach(CdfConfig::dc_codes_file, :headers => true) do |row|
  DcCode.find_or_create_by_po_dc_code(row[0],
                                      :poa_dc_code => row[1],
                                      :asn_dc_code => row[2],
                                      :inv_dc_san => row[3],
                                      :dc_name => row[4]
  )
end

CdfBindingCode.find_or_create_by_code('M', :name => 'Mass Market')
CdfBindingCode.find_or_create_by_code('A', :name => 'Audio Products')
CdfBindingCode.find_or_create_by_code('T', :name => 'Trade Paper')
CdfBindingCode.find_or_create_by_code('H', :name => 'Hard Cover')
CdfBindingCode.find_or_create_by_code('', :name => 'Other')

AsnOrderStatus.find_or_create_by_code('00', :description => 'Shipped')
AsnOrderStatus.find_or_create_by_code('26', :description => 'Canceled')
AsnOrderStatus.find_or_create_by_code('28', :description => 'Partial Shipment')
AsnOrderStatus.find_or_create_by_code('95', :description => 'Backorder canceled by date')
AsnOrderStatus.find_or_create_by_code('96', :description => 'Backorder canceled by client')

AsnSlashCode.find_or_create_by_code('Slash', :description => '(SLN 04 - price qualifier "SR"')
AsnSlashCode.find_or_create_by_code('11', :description => 'Unable to commit')
AsnSlashCode.find_or_create_by_code('12', :description => 'Slash/Cancel')
AsnSlashCode.find_or_create_by_code('A1', :description => 'Auto-Slash')
AsnSlashCode.find_or_create_by_code('S1', :description => 'DC Slash (warehouse)')

# Load States
CSV.foreach(CdfConfig::states_file) do |row|
  country = Country.find_by_numcode(row[2])
  if country.nil?
    next
  end

  state = State.find_by_name(row[0])
  if state.nil?
    state = State.create({abbr: row[0], name: row[1], country: country})
  end
  state.abbr = row[0]
  state.save
end

po_box_yes = PoBoxOption.find_or_create_by_name('Yes')
po_box_no = PoBoxOption.find_or_create_by_name('No')
po_box_depends = PoBoxOption.find_or_create_by_name('Dependant on ship-to country')

intl = AddressType.find_or_create_by_code('intl', :name => 'International')
domestic = AddressType.find_or_create_by_code('us', :name => 'Domestic')


AsnShippingMethodCode.find_or_create_by_code('12',
                                             :address_type => 'Domestic',
                                             :shipping_method => '2nd Day Air',
                                             :big_bisac_code_sent_in => '### 2ND DAY AIR',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('17',
                                             :address_type => 'Domestic',
                                             :shipping_method => '3 Day Select',
                                             :big_bisac_code_sent_in => '### 3 DAY SELECT',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('10',
                                             :address_type => 'Domestic',
                                             :shipping_method => 'Ground',
                                             :big_bisac_code_sent_in => '### UPS',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('11',
                                             :address_type => 'Domestic',
                                             :shipping_method => 'Next Day Air',
                                             :big_bisac_code_sent_in => '### NEXT DAY AIR',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('1A',
                                             :address_type => 'Domestic',
                                             :shipping_method => 'Next Day Air Saver',
                                             :big_bisac_code_sent_in => '### NEXT DAY AIR SAVER',
                                             :po_box_option_id => po_box_no.id)

AsnShippingMethodCode.find_or_create_by_code('21',
                                             :address_type => 'Domestic',
                                             :shipping_method => 'Economy Mail',
                                             :big_bisac_code_sent_in => '### USA ECONOMY',
                                             :po_box_option_id => po_box_yes.id)

AsnShippingMethodCode.find_or_create_by_code('24',
                                             :address_type => 'Domestic',
                                             :shipping_method => 'Expedited Mail',
                                             :big_bisac_code_sent_in => '### USA EXPEDITED',
                                             :po_box_option_id => po_box_yes.id)

AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL COURIER',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :shipping_method => 'INTL Courier (trackable) **',
                                                               :po_box_option_id => po_box_depends.id,
                                                               :notes => 'not available in Puerto Rico')

AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL PRIORITY',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :shipping_method => 'INTL Priority (non-trackable)',
                                                               :big_bisac_code_sent_in => '',
                                                               :po_box_option_id => po_box_yes.id)

AsnShippingMethodCode.find_or_create_by_big_bisac_code_sent_in('### INTL W/DEL CONFIRMATION',
                                                               :code => '50',
                                                               :address_type => 'International',
                                                               :shipping_method => 'INTL with Delivery Confirmation ** *',
                                                               :big_bisac_code_sent_in => '',
                                                               :po_box_option_id => po_box_depends.id,
                                                               :notes => 'only available for Canada, Great Britain, and Japan')
