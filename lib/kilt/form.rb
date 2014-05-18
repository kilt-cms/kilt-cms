module Kilt
  module Form
    
    TEMPLATES_DIR = if ENV['RAILS_ENV'] == 'test'
                      '/'
                    else
                      "#{Kilt::Engine.root}/app/views/kilt/form"
                    end
    
    def self.method_missing(method, *args)
      locals = { object: args[0], field_name: args[1], index: args[2], options: args[4], view: args[3] }
      render_view method, locals
    rescue
      render_view 'default', locals
    end

    def self.render_field(view, data)
      Kilt::Form.prep_field(data[:value], data[:object], data[:key], data[:index], view)
    end
    
    def self.prep_field(method, *args)
      # This is a method called before the generic method_missing.
      # In this method, we'll parse out the method value to see if there are
      # any options being passed in with the name of the field.
      # Example: select(small|large)
      if (method.include? "(") && (method.include? ")")
        first_split = method.split("(")
        method_name = first_split.first
        
        # Now get the option values and push them onto the arg stack
        second_split = first_split[1].split(")")
        options = second_split.first
        if options
          args << options
        end
      else
        method_name = method
      end
      self.send(method_name.strip, *args)
    end

    private

    def self.render_view name, locals
      data = { :file    =>  "#{name.to_s}.html.erb",
               :locals  => locals }
      #ActionView::Base.new(TEMPLATES_DIR).render data
      locals[:view].send(:render, { partial: "kilt/form/#{name}", locals: locals } )
    end
    
  end
end
