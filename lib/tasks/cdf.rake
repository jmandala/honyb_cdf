namespace :cdf do
  namespace :db do

    desc 'Load the seed data from db/seeds.rb'
    task :seed => 'db:abort_if_pending_migrations' do
      seed_file = File.join(Rails.root, 'cdf', 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end


    desc 'Run database tasks'
    task :clean do
      Order.update_all('po_file_id = NULL', 'po_file_id IS NOT NULL')
      PoFile.all.each { |p| p.destroy }
      PoaFile.all.each { |p| p.destroy }
      AsnFile.all.each { |f| f.destroy }

      ### Create POA_Files for any records without them, in the Data_Lib ###
      Dir.glob(CdfConfig::current_data_lib_in + "/*.fbc").each do |f|
        file_name = File.basename(f)
        PoaFile.create(:file_name => file_name) unless PoaFile.find_by_file_name(file_name)
      end

      ### Create ASN_Files for any records without them, in the Data_Lib ###
      Dir.glob(CdfConfig::current_data_lib_in + "/*.pbs").each do |f|
        file_name = File.basename(f)
        AsnFile.create(:file_name => file_name) unless AsnFile.find_by_file_name(file_name)
      end
    end

  end
end