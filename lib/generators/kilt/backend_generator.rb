module Kilt
  module Generators
    class BackendGenerator < Rails::Generators::Base
      
      desc "Generates the Kilt backend"
      
      source_root File.expand_path("../templates/backend", __FILE__)
      
      def generate
        add_the_config_file
        add_the_credential_file_examples
        add_the_database_migration_file
        add_the_kilt_routes
        add_the_initializer
      end

      private

      def add_the_config_file
        template 'config.yml.erb', Rails.root.join('config', 'kilt', 'config.yml')
      end

      def add_the_credential_file_examples
        copy_file 'creds.yml.example', Rails.root.join('config', 'kilt', 'creds.yml')
      end

      def add_the_database_migration_file
        copy_file 'create_kilt_objects.rb', Rails.root.join('db', 'migrate', Time.now.strftime("%Y%m%d%H%M%S") + "_create_kilt_objects.rb")
      end

      def add_the_kilt_routes
        inject_into_file Rails.root.join('config', 'routes.rb'), "\n\tmount Kilt::Engine => '/admin', as: 'kilt_engine'\n", :after => ".routes.draw do\n"
      end

      def add_the_initializer
        copy_file 'kilt.rb', Rails.root.join('config', 'initializers', 'kilt.rb')
      end

    end
  end
end
