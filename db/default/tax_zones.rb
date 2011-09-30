puts "TaxCategory..."
taxable_goods = TaxCategory.find_or_create_by_name('Taxable Goods', :is_default => true, :description => 'Goods for which tax must be collected')

puts "TaxRate..."

rates = {:MA => 0.0625, :ME => 0.05}

rates.keys.each do |key|
  abbr = key.to_s
  rate = rates[key]
  state = State.find_by_abbr abbr
  
  puts "\tCreate tax rate for #{abbr} -> #{rate.to_s}"
  
  # create the tax zone
  zone = Zone.find_or_create_by_name("#{abbr}_TAX")

  unless zone.includes_zoneable? state
    member = ZoneMember.create(:zone => zone, :zoneable => state, :zoneable_type => 'State')
    zone.members << member
  end

  # create the tax rate
  TaxRate.find_or_create_by_zone_id(zone.id, :amount => rate, :tax_category => taxable_goods)
end

