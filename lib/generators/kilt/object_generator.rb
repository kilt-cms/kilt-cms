module Kilt
  module Generators
    class ObjectGenerator < Rails::Generators::Base
      desc "adds objects and their properties to the configuration file"
      argument :object_name, :type => :string, :required => true, :desc => "required"
      argument :fields, :type => :array, :required => true, :desc => "required field_name:field_type"
      
      def generate
        if !Kilt.config.objects || !Kilt.config.objects[self.object_name.singularize.underscore]
          out = "\n\s\s#{self.object_name.singularize.underscore}:"
          out = "#{out}\n\s\s\s\sfields:"
          self.fields.each do |field|
            field = field.gsub(':',': ')
            out = "#{out}\n\s\s\s\s\s\s#{field.downcase}"
          end
          append_to_file Rails.root.join('config', 'kilt', 'config.yml'), out
        else
          puts "The #{self.object_name} object already exists"
        end
      end
    end
  end
end