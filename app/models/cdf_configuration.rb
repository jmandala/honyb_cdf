class CdfConfiguration < Configuration

  preference :po_files_per_page, :integer, :default => 30
  preference :poa_files_per_page, :integer, :default => 30

  preference :cdf_ship_to_password, :string, :default => ""
  preference :cdf_ship_to_account, :string, :default => ""
  preference :cdf_bill_to_account, :string, :default => ""
  preference :cdf_ftp_server, :string, :default => "ftp1.ingrambook.com"
  preference :cdf_ftp_user, :string, :default => ""
  preference :cdf_ftp_password, :string, :default => ""
  preference :cdf_run_mode, :string, :default => :test

  preference :days_to_hold_backorder, :integer, :default => 1
  preference :split_shipment_type, :string, :default => :release_when_full
  
  PER_PAGE = [25, 50, 75, 100, 150, 200]
end