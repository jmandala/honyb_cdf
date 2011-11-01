require 'spree_core'
require 'cdf_hooks'

# include the ext
Dir.glob(File.join(File.dirname(__FILE__), "ext/**/*.rb")) do |c|
  Rails.env.production? ? require(c) : load(c)
end

# include the ext
Dir.glob(File.join(File.dirname(__FILE__), "fixed_width/**/*.rb")) do |c|
  Rails.env.production? ? require(c) : load(c)
end

module Cdf
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      Calculator::AdvancedFlexiRate.register       

    end

    config.to_prepare &method(:activate).to_proc
  end

end
