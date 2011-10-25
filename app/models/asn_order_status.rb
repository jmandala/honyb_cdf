class AsnOrderStatus < ActiveRecord::Base
  def shipped?
    self.code == '00'
  end
  
  def partial_shipment?
    self.code == '28'
  end
  
  def canceled?
    self.code == '26'
  end
end
