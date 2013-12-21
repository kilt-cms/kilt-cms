$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kilt-cms"
  s.version     = "0.5.1"
  s.authors     = ["Ashe Avenue"]
  s.email       = ["community@asheavenue.com"]
  s.homepage    = "http://community.asheavenue.com"
  s.summary     = "Microsite Platform for Rails 4"
  s.description = "Microsite Platform for Rails 4 built with RethinkDB"
  s.license     = 'MIT'
  
  s.required_ruby_version = '>= 2.0.0'

  s.files = Dir["{app,config,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '>= 4.0.1'
  s.add_dependency 'rethinkdb'
  s.add_dependency 'rails_config'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'compass-rails'
  s.add_dependency 'uglifier'
  s.add_dependency 'aws-sdk'

  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'meta_request'
  s.add_development_dependency 'rspec-rails'
  
end
