module Kilt
  module Form
    
    TEMPLATES_DIR = "#{Kilt::Engine.root}/app/views/kilt/form"
    
    def self.method_missing(method, *args)
      begin
        
        # Get the method name
        name = method.to_s
        
        # Get the object type and field name
        object = args[0]
        field_name = args[1]
        index = args[2]
        
        # Render the corresponding form field, or fall back to the default if we have an issue
        begin
          ActionView::Base.new(TEMPLATES_DIR).render(:file => "#{name}.html.erb", :locals => {:object => object, :field_name => field_name, :index => index})
        rescue
          ActionView::Base.new(TEMPLATES_DIR).render(:file => "_default.html.erb", :locals => {:object => object, :field_name => field_name, :index => index})
        end
        
      end
    end
    
  end
end