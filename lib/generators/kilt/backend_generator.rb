module Kilt
  module Generators
    class BackendGenerator < Rails::Generators::Base
      
      desc "Generates the Kilt backend"
      
      source_root File.expand_path("../templates/backend", __FILE__)
      
      def generate
        
        #copy files, templates for app-specific naming, inject engine mount to routes
        template 'config.yml.erb', Rails.root.join('config', 'kilt', 'config.yml')
        copy_file 'creds.yml.example', Rails.root.join('config', 'kilt', 'creds.yml.example')
        copy_file 'creds.yml.rethinkdb.example', Rails.root.join('config', 'kilt', 'creds.yml.rethinkdb.example')
        copy_file 'create_kilt_objects.rb', Rails.root.join('db', 'migrate', Time.now.strftime("%Y%m%d%H%M%S") + "_create_kilt_objects.rb")
        copy_file 'kilt.rb', Rails.root.join('config', 'initializers', 'kilt.rb')
        inject_into_file Rails.root.join('config', 'routes.rb'), "\n\tmount Kilt::Engine => '/admin', as: 'kilt_engine'\n", :after => ".routes.draw do\n"
      
      end
    end
  end
end
