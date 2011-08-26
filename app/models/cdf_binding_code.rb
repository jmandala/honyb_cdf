class CdfBindingCode < ActiveRecord::Base
  def self.other_code
    where(:code => '').first
  end

end
