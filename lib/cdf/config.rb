module Cdf
  class Config < Spree::Config
    RUN_MODE = [:live, :test, :mock]
    
    class << self
      
      def instance
        return nil unless ActiveRecord::Base.connection.tables.include?('configurations')
        CdfConfiguration.find_or_create_by_name("CDF configuration")
      end
    end
  end
end