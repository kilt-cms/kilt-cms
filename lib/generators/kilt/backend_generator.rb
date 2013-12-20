module Kilt
  module Generators
    class BackendGenerator < Rails::Generators::Base
      desc "Generates the Kilt backend"
      
      source_root File.expand_path("../templates/backend", __FILE__)
      
      def generate
        #if using git, add creds config to .gitignore
        append_file Rails.root.join('.gitignore'), '/config/kilt/creds.yml' if File.exists? Rails.root.join('.gitignore')
        #copy files, templates for app-specific naming, inject engine mount to routes
        template 'config.yml.erb', Rails.root.join('config', 'kilt', 'config.yml')
        copy_file 'creds.yml.example', Rails.root.join('config', 'kilt', 'creds.yml.example')
        copy_file 'kilt.rb', Rails.root.join('config', 'initializers', 'kilt.rb')
        inject_into_file Rails.root.join('config', 'routes.rb'), "\n\tmount Kilt::Engine => '/admin'\n", :after => "#{Rails.application.class.parent_name.camelize}::Application.routes.draw do\n"
      end
    end
  end
end