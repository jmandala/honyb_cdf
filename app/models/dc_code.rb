class DcCode < ActiveRecord::Base
  has_many :orders
  
  def self.default
    find_by_po_dc_code(nil)
  end
end
