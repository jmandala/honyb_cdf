require 'csv'

module Import
  class Zone

    def self.load_states
      data = []
      CSV.foreach(File.dirname(__FILE__) + "/State.txt") do |row|
        country = Country.find_by_numcode(row[2])
        if country.nil?
          data << "No country for id: #{row[2]}"
          next
        end

        state = State.find_by_name(row[0])
        if state.nil?
          state = State.create({abbr: row[0], name: row[1], country: country})
        end
        state.abbr = row[0]
        state.save
        data << state
      end
      data
    end


  end
end
