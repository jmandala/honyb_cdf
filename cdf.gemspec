Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'cdf'
  s.version     = '0.60.1'
  s.summary     = 'CDF/Ingram Integration'
  s.description = 'Provides integration with Ingram\'s CDFLit Fulfillment'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Joshua Jacobs'
  s.email             = 'josh@mandala-designs.com'
  s.homepage          = 'http://honyb.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency('spree_core', '>= 0.60.1')
  s.add_dependency('haml')
  s.add_dependency('haml')
  
  s.add_dependency('cucumber-rails')
  s.add_dependency('rspec-rails')
end
