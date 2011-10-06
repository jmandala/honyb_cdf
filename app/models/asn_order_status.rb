class AsnOrderStatus < ActiveRecord::Base
  def shipped?
    self.code == '00'
  end
end
