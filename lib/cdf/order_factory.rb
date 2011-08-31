require File.join File.dirname(__FILE__ ), '../../../spec/factories'

class Cdf::OrderFactory
  
  def self.new
    order = FactoryGirl.create(:order)
    order.init_test
  end
end
