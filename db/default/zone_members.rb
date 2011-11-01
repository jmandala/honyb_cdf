puts "ZoneMember..."
puts "USA Zones"
continental_zone = Zone.find_or_create_by_name('Continental USA', :description => 'Continental United States')
non_continental_zone = Zone.find_or_create_by_name('Non-continental USA', :description => 'Non-continental United States')
armed_forces_zone = Zone.find_or_create_by_name('APO/AFO', :description => 'US Armed Forces')
territories_zone = Zone.find_or_create_by_name('US Territories', :description => 'United States Territories & Minor Outlying Islands')
all_usa_zone = Zone.find_or_create_by_name('ALL US', :description => 'All US Sates & Territories, Including Armed Forces')

non_continental_states = %w(HI AK)
armed_forces_states = %w(AP AA AE)
territories = %w(MH PW FM AS GU MP PR VI UM)

# add states to correct zone
puts "\tAdd states to correct zone"
Country.find_by_iso('US').states.order('abbr asc').each do |state|
  if non_continental_states.include?(state.abbr)
    zone = non_continental_zone 
  elsif armed_forces_states.include?(state.abbr)
    zone = armed_forces_zone
  else
    zone = continental_zone
  end

  next if zone.includes_zoneable? state

  puts "#{state.abbr} -> #{zone.name}"
  member = ZoneMember.create(:zone => zone, :zoneable => state, :zoneable_type => 'State')
  zone.members << member
end

puts "\tAdd territories to territory_zone"
territories.each do |t|
  state = State.find_by_abbr!(t)  
  next if territories_zone.includes_zoneable? state
  puts "\t\t#{state.abbr} -> #{territories_zone.name}"
  member = ZoneMember.create(:zone => territories_zone, :zoneable => state, :zoneable_type => 'State')
  territories_zone.members << member
end
    
puts "\tAdd all us zones to USA"
[continental_zone, non_continental_zone, armed_forces_zone, territories_zone].each do |zone|
  next if all_usa_zone.includes_zoneable? zone
  member = ZoneMember.create(:zone => all_usa_zone, :zoneable => zone, :zoneable_type => 'Zone')
  all_usa_zone.members << member
end

puts "International Zone"
intl_zone = Zone.find_or_create_by_name('International', :description => 'International Zone')
Country.where('iso not in (?)', Zone.find_by_name('ALL US').country_list.collect(&:iso)).each do |country|
  intl_zone.members << ZoneMember.create(:zone => intl_zone, :zoneable => country, :zoneable_type => 'Country')
end