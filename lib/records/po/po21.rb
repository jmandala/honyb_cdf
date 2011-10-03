module Records
  module Po

# Purchase Order Options Record
    class Po21 < PoBase

      PO_TYPE = {
          :purchase_order => '0',
          :request_confirmation => '1',
          :reserved => '2',
          :stock_status_request => '3',
          :reserved => '4',
          :specific_confirmation => '5',
          :request_confirmation_web_service => '7',
          :test_purchase_order => '8'
      }

      # The POA Type allows you to define the amount of detail that will be returned in the POA.
      # It is specified in the PO file and returned in the POA File Header to indicate which records
      # will be included in the POA file. One of the following codes should be entered in the PO Record 21, position 44
      # 1 = Full Acknowledgement -- all records
      # 2 = no 42 and 43 records
      # 3 = no 44 records
      # 4 = no 42, 43, or 44 records
      # 5 = Exception Acknowledgement -- report only the lines where an exception has occurred
      POA_TYPE = {
          :full_acknowledgement => '1',
          :no_42_and_43_records => '2',
          :no_44_records => '3',
          :no_42_43_or_44_records => '4',
          :exception_acknowledgement => '5'
      }

      
      def cdf_record
        cdf = super
        cdf << ingram_ship_to_account_number
        cdf << po_type
        cdf << split_shipment_type
        cdf << dc_code
        cdf << reserved(1)
        cdf << green_light
        cdf << reserved(1)
        cdf << poa_type
        cdf << ship_to_password
        cdf << shipping_method
        cdf << reserved(1)
        cdf << allow_split_order_across_dc
        cdf << reserved(1)

        PoBase.ensure_length cdf
      end


      def ingram_ship_to_account_number
        Cdf::Config.get(:cdf_ship_to_account).ljust_trim 7
      end

      def po_type
        if Cdf::Config.get(:cdf_run_mode).nil?
          Cdf::Config.set({:cdf_run_mode => 'false'})
        end

        # Never send test orders while in TEST_MODE
        if Cdf::Config.get(:cdf_run_mode) == 'true'
          return PO_TYPE[:purchase_order].ljust_trim(1)
        end

        # todo: make a way to pass in the PO_TYPE
        PO_TYPE[:purchase_order].ljust_trim 1

      end

      def split_shipment_type
        @order.split_shipment_type.ljust_trim 2
      end

      # Distribution Center code. Blank to use default
      def dc_code
        @order.dc_code.po_dc_code || ' '
      end

      # "Y" or "N". Greenlight titles are usually low demand titles with a short-discount (less than 35%)
      def green_light
        "Y"
      end

      def poa_type
        POA_TYPE[:full_acknowledgement].ljust_trim 1
      end

      def ship_to_password
        Cdf::Config.get(:cdf_ship_to_password).ljust_trim 8
      end

      # Address   Shipping Method     Big BISAC Code Sent     ASN Allow PO Box
      # Domestic 	2nd Day Air 	      ### 2ND DAY AIR 	      12 	No
      #           3 Day Select 	      ### 3 DAY SELECT 	      17 	No
      #           Ground 	            ### UPS 	              10 	No
      #           Next Day Air 	      ### NEXT DAY AIR       	11 	No
      #           Next Day Air Saver 	### NEXT DAY AIR SAVER 	1A 	No
      #           Economy Mail      	### USA ECONOMY       	21 	Yes
      #           Expedited Mail    	### USA EXPEDITED     	24 	Yes
      # International
      #           INTL Courier (trackable) **         	### INTL COURIER 	            50 	Dependant on ship-to country
      #           INTL Priority (non-trackable)       	### INTL PRIORITY            	50 	Yes
      #           INTL with Delivery Confirmation ***  	### INTL W/DEL CONFIRMATION 	50 	Dependant on ship-to country
      def shipping_method
        @order.shipping_method.asn_shipping_method_code.big_bisac_code_sent_in.ljust_trim(25)
      end

      # Y = Yes
      # N = No
      # blank = use default
      def allow_split_order_across_dc
        "Y"
      end

    end
  end
end