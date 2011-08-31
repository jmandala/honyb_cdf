require File.join File.dirname(__FILE__ ), '../../../spec/factories'

class Cdf::OrderBuilder
  
  SCENARIOS = [
  {:id => 1, :name => 'single order/single line/single quantity'},
  {:id => 2, :name => 'single order/single line/multiple quantity'},
  {:id => 3, :name => 'single order/multiple lines/single quantity'},
  {:id => 4, :name => 'single order/multiple lines/multiple quantity'}
  ]
  
  def self.new
    order = Order.new_test
  end
end
