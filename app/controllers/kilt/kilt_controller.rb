module Kilt
  class KiltController < ActionController::Base
    layout 'kilt/cms'
    protect_from_forgery
    before_filter :ensure_config
    
    # Show all the object types
    def index
      @types = Kilt.types
    end
  
    # Show the list of items for a specific object type
    def list
      @type = params[:types].singularize
      @objects = Kilt.send(@type.pluralize).order('name')
    end
  
    # Create a new object
    def new
      @type = params[:types].singularize
      @object = Kilt::Object.new(@type)
    end
  
    # Post back a new object
    def create
      type = params[:types].singularize
      
      # Get the params
      p = params[type]
      
      # Ensure we have a name
      if p['name'] == ''
        flash[:error] = "Name is required"
        redirect_to new_object_path(type.pluralize)
      else
        # Create an object and fill it with the values passed in by the form
        object = Kilt::Object.new(type)
        object.fill(p)
        
        # Call Kilt's update method
        if Kilt.create(object)
          flash[:notice] = "#{type.capitalize} successfully updated"
          redirect_to edit_object_path(type.pluralize, object.slug)
        else
          flash[:error] = "Couldn't save #{type.capitalize}"
          redirect_to new_object_path(type.pluralize)
        end
      end
      
    end
  
    # View/Edit a specific object
    def edit
      @type = params[:types].singularize
      @slug = params[:slug]
      @object = Kilt.get(@slug)
    end
  
    # Update an object
    def update
      type = params[:types].singularize
      slug = params[:slug]
      
      # Get the params
      p = params[type]
      
      # Ensure we have a name
      if p['name'] == ''
        flash[:error] = "Name is required"
        redirect_to edit_object_path(type.pluralize, slug)
      else
        # Create an object and fill it with the values passed in by the form
        object = Kilt.get(slug)
        object.fill(p)
      
        # Call Kilt's update method
        if Kilt.update(slug, object)
          flash[:notice] = "#{type.capitalize} successfully updated"
        else
          flash[:error] = "Couldn't save #{type.capitalize}"
        end
      
        # redirect to the edit screen
        redirect_to edit_object_path(type.pluralize, object.slug)
      end
    end
  
    # Delete an object
    def delete
      type = params[:types].singularize
      slug = params[:slug]
      object = Kilt.get(slug)
      
      # Call Kilt's update method
      if Kilt.delete(slug)
        flash[:notice] = "#{type.capitalize} successfully deleted"
      else
        flash[:error] = "Couldn't delete #{type.capitalize}"
      end
      
      # redirect to the list screen
      redirect_to list_path(type.pluralize)
    end
    
    private
    
    def ensure_config
      if Kilt.config.empty? || !Kilt.config.db
        lines = []
        lines << '<pre>'
        lines << 'The Kilt gem has been installed, but you haven\'t configured it yet.'
        lines << 'Start configuring Kilt by running the following command:'
        lines << ''
        lines << '   rails g kilt:backend'
        lines << ''
        lines << 'Then open config/kilt/config.yml and config/kilt/creds.yml, add your database information, define your data model, start Rails, and visit http://&lt;your_app&gt;/admin'
        lines << '</pre>'
        render :text => lines.join("\n")
      end
    end
  end
end
