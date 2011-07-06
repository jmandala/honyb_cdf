# For each file in the datalib IN, create a POA_File if none exists
Dir.glob(CdfConfig::current_data_lib_in + "/*.fbc").each do |f|
  file_name = File.basename(f)
  PoaFile.create(:file_name => file_name) unless PoaFile.find_by_file_name(file_name)
end