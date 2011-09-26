module DataDisplay
  class DataView
    def self.data_pair(field_name)
      """
      <div class='#{field_name}'><label>#{field_name}</label></div>
      """
    end
  end
end