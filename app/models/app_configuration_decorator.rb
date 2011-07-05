AppConfiguration.class_eval do
  preference :po_files_per_page, :integer, :default => 30
  preference :poa_files_per_page, :integer, :default => 30
  preference :cdf_ship_to_password, :string, :default => ""
  preference :cdf_ship_to_account, :string, :default => ""
  preference :cdf_bill_to_account, :string, :default => ""
  preference :cdf_ftp_server, :string, :default => "ftp1.ingrambook.com"
  preference :cdf_ftp_user, :string, :default => ""
  preference :cdf_ftp_password, :string, :default => ""

end