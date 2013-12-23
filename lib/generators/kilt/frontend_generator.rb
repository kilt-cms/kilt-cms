module Kilt
  module Generators
    class FrontendGenerator < Rails::Generators::Base
      desc "Generates a bootstrap for the host application"
      
      source_root File.expand_path("../templates/frontend",__FILE__)
      
      def generate
        #copy files, templates for app-specific naming, inject index action into routs
        template 'home_controller.rb.erb', Rails.root.join('app', 'controllers', "#{file_name}_controller.rb")
        copy_file 'application.html.erb', Rails.root.join('app','views','layouts','application.html.erb')
        copy_file 'index.html.erb', Rails.root.join('app', 'views', "#{file_name}", 'index.html.erb')
        inject_into_file Rails.root.join('config','routes.rb'),"\n\tget '/' => '#{file_name}#index'\n", :after => "mount Kilt::Engine => '/admin', as: 'kilt_engine'\n"
        #handle assets, sans named files
        directory 'assets/images', Rails.root.join('app','assets','images')
        directory 'assets/javascripts', Rails.root.join('app','assets','javascripts')
        directory 'assets/stylesheets', Rails.root.join('app','assets','stylesheets')
        #handle named files
        template 'dummy.js.erb', Rails.root.join('app','assets','javascripts',"#{file_name}.js")
      end
      
      private
      
      def file_name
        Rails.application.class.parent_name.underscore
      end
      
      def class_name
        Rails.application.class.parent_name.camelize
      end
    end
  end
end