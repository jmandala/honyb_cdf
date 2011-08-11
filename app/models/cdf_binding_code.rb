class CdfBindingCode < ActiveRecord::Base
  def self.other
    where(:code => '').first
  end

end
