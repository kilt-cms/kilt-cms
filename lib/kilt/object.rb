module Kilt
  class Object
    attr_accessor :type, :fields, :values, :slug

    def initialize(type, values = {})
      @type = type
      @values = values

      assemble_fields
    end

    def fill(params)
      puts params
      # Take the params passed in and match them up to the fields
      @fields.each do |key, value|
        if params[key] || params["#{key}-hidden"]
          field_type = value.downcase
          if ['file', 'image'].include? field_type
            if params["#{key}-hidden"] && params["#{key}-hidden"] == 'clear' && !params[key]
              @values[key.to_s] = ''
            elsif params[key]
              @values[key.to_s] = Kilt::Upload.send(field_type, params[key])
            end
          else
            @values[key.to_s] = params[key]
          end
        end
      end

      # Add some extra fields
      if !@slug
        @values['slug'] = Utils.slugify(@values['name'])
      end
      
      @values['type'] = @type

    end

    def [](key)
      # Return the values of the object as a hash
      value = @values[key.to_s]
      return nil unless value
      value.respond_to?(:html_safe) ? value.html_safe : value
    end

    def []=(key, value)
       @values[key.to_s] = value
    end

    def slug
      @values['slug']
    end

    def empty?
      @values.length == 0
    end

    private

    def assemble_fields
      # Get the fields from the config, and add the name field
      @fields = Kilt.send(@type).fields.map { |key, value| [key, value] }
      if !Kilt.send(@type).fields.to_h.has_key? :name
        @fields.insert(0, ['name', 'text'])
      end
    end
  end
end