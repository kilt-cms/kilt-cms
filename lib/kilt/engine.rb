require 'rubygems'
require 'rethinkdb'
require 'rails_config'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'aws/s3'

module Kilt
  class Engine < ::Rails::Engine
    
    isolate_namespace Kilt
    
    config.generators.integration_tool :rspec 
    config.generators.test_framework :rspec
          
  end
end