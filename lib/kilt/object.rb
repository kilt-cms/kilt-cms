module Kilt
  class Object
    attr_accessor :type, :fields, :values, :slug

    def initialize(type, values = {})
      @type = type
      initialize_values values
      assemble_fields
    end

    def fill(params)
      fields_that_should_be_set_given(params).each do |field, field_type|
        self[field] = the_value_for field, field_type, params
      end
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

    def the_value_for(key, field_type, params)
      if params["#{key}-hidden"] && params["#{key}-hidden"] == 'clear' && !params[key]
        ''
      elsif ['file', 'image'].include? field_type
        Kilt::Upload.send(field_type, params[key])
      else
        params[key]
      end
    end

    def fields_that_should_be_set_given params
      @fields.map    { |k, v| [k, v.downcase] }
             .select { |k, v| params[k] || params["#{k}-hidden"] }
    end

    def initialize_values values
      @values = values

      @values.keys
             .select { |x| x.is_a? Symbol }
             .each   { |k| @values[k.to_s] = @values[k] }
    end

  end
end
