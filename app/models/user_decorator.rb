User.class_eval do

  COMPLIANCE_EMAIL = "compliance.test@honyb.com"

  # Creates a user to assign to compliance test orders
  def self.compliance_tester!
    token = User.generate_token(:persistence_token)
    User.create(:email => COMPLIANCE_EMAIL, :password => token, :password_confirmation => token, :persistence_token => token)
  end  
  
  def compliance_tester?
    email =~ /#{COMPLIANCE_EMAIL}/
  end
  
end
