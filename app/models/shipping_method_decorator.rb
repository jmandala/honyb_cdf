ShippingMethod.class_eval do
  
  has_one :asn_shipping_method_code

  
  def available?(order, display_on=nil)
    display_check = (self.display_on == display_on.to_s || self.display_on.blank?)
    calculator_check = calculator.available?(order)
    valid_for_environment? && display_check && calculator_check
  end
  
  # True if environment is not set, or current environment matches set environment
  def valid_for_environment?
    current_env = ENV['RAILS_ENV']
    self.environment.nil? || current_env.nil? || self.environment.split(/,/).include?(current_env)
  end

end
