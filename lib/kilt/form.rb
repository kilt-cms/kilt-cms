module Kilt
  module Form
    
    TEMPLATES_DIR = if ENV['RAILS_ENV'] == 'test'
                      '/'
                    else
                      "#{Kilt::Engine.root}/app/views/kilt/form"
                    end
    
    def self.method_missing(method, *args)
      locals = { object: args[0], field_name: args[1], index: args[2] }
      render_view method, locals
    rescue
      render_view '_default', locals
    end

    private

    def self.render_view name, locals
      data = { file:   "#{name.to_s}.html.erb",
               locals: locals }
      ActionView::Base.new(TEMPLATES_DIR).render data
    end
    
  end
end
