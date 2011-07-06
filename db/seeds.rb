require 'csv'

Order.update_all('po_file_id = NULL', 'po_file_id IS NOT NULL')
PoFile.delete_all
PoaFile.delete_all
PoaOrderHeader.delete_all

### Create POA_Files for any records without them, in the Data_Lib ###
Dir.glob(CdfConfig::current_data_lib_in + "/*.fbc").each do |f|
  file_name = File.basename(f)
  PoaFile.create(:file_name => file_name) unless PoaFile.find_by_file_name(file_name)
end


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
  Rails.logger.info "Update Row: #{row}"
  PoStatus.find_or_create_by_code(row[0], :name => row[1])
end

CSV.foreach(CdfConfig::poa_status_file) do |row|
  Rails.logger.info "Update Row: #{row}"
  PoaStatus.find_or_create_by_code(row[0], :name => row[1])
end
