module Kilt
  module Generators
    class ObjectGenerator < Rails::Generators::Base
      
      desc "adds objects and their properties to the configuration file"
      
      # The object name and field name/type definitions
      argument :object_name, :type => :string, :required => true, :desc => "required"
      argument :fields, :type => :array, :required => true, :desc => "required field_name:field_type"
      
      def generate
        if !Kilt.config.objects || !Kilt.config.objects[self.object_name.singularize.underscore]
          
          # Build the object entry
          lines = []
          lines << "\n\s\s#{self.object_name.singularize.underscore}:"
          lines << "\n\s\s\s\sfields:"
          self.fields.each do |field|
            field = field.gsub(':',': ')
            lines << "\n\s\s\s\s\s\s#{field.downcase}"
          end
          
          # Write the object entry to the kilt config
          append_to_file Rails.root.join('config', 'kilt', 'config.yml'), lines.join('')
          
        else
          puts "The #{self.object_name} object already exists"
        end
      end
    end
  end
end