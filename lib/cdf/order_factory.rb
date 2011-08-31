require File.join File.dirname(__FILE__ ), '../../../spec/factories'

class Cdf::OrderFactory
  
  SCENARIOS = [
  {:id => 1, :name => 'single order/single line/single quantity'},
  {:id => 2, :name => 'single order/single line/multiple quantity'},
  {:id => 3, :name => 'single order/multiple lines/single quantity'},
  {:id => 4, :name => 'single order/multiple lines/multiple quantity'}
  ]
  
  def self.new
    order = FactoryGirl.create(:order)
    order.to_test
  end
end
