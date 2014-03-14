require "kilt/base"

# Include the Rethink shortcut module, which will among other things instantiate a new
# Rethink object (as "r") if needed
include RethinkDB::Shortcuts

module Kilt
  
  # Hold the config object
  mattr_accessor :config
  
  # Auto-generated endpoints
  def self.method_missing(method, *args)
    begin
      
      if Utils.is_singular? method.to_s
        # Get the configuration for a type
        # Example: Kilt.event
        Kilt.config.objects[method]
      else
        # Get a list of objects
        # Example: Kilt.events
        Kilt.get_collection method.to_s 
      end
    end
  end
  
  # Get the list of types
  # Returns: array of type names
  # Example: Kilt.types
  def self.types
    Kilt.config.objects.map { |key, value| key.to_s }
  end
  
  
  # Create an object
  # Returns: boolean
  # Example: Kilt.create(object)
  def self.create(object)
    object['created_at'] = object['updated_at'] = Time.now
    object['unique_id']  = "#{(Time.now.to_f * 1000).to_i}"
    object['type']       = object.instance_eval { @type }
    object['slug']       = Utils.slugify(object['name'])

    result = Utils.db do
      
      # Check for slug uniqueness
      unless slug_is_unique? object['slug']
        object['slug'] = "#{object['slug']}-#{(Time.now.to_f * 1000).to_i}"
      end
      
      # Insert the record
      r.db(Kilt.config.db.db).table('objects').insert(object.values).run
      
    end

    result['errors'] == 0
  end

  # Update an object
  # Returns: boolean
  # Example: Kilt.update(object)
  def self.update(slug, object)
    object['updated_at'] = Time.now
    result = Utils.db do
      
      # Keep the original slug handy
      results = r.db(Kilt.config.db.db).table('objects').filter({'slug' => "#{slug}"}).limit(1).run
      original = results.to_a.first['unique_id']
      
      # Check for slug uniqueness
      results = r.db(Kilt.config.db.db).table('objects').filter({'slug' => "#{object['slug']}"}).run
      if results
        result = results.to_a.first
        if result && result['unique_id'] != original
          object['slug'] = "#{Kilt::Utils.slugify(object['name'])}-#{(Time.now.to_f * 1000).to_i}"
        end
      end
      
      # Update the record
      r.db(Kilt.config.db.db).table('objects').filter({'unique_id' => "#{original}"}).update(object.values).run
      
    end
    (result['errors'] == 0)
  end


  # Delete an object
  # Returns: boolean
  # Example: Kilt.delete('some-object')
  def self.delete(slug)
    result = Utils.db do
      r.db(Kilt.config.db.db).table('objects').filter({'slug' => "#{slug.to_s}"}).delete().run
    end
    (result['errors'] == 0)
  end

  # Get the content for a specific object
  # Returns: Kilt::Object instance
  # Example: Kilt.object('big-event')
  def self.get(slug)
    # connect to the db, get the object, close the connection, return the object
    values = Utils.db do
      r.db(Kilt.config.db.db).table('objects').filter({'slug' => "#{slug.to_s}"}).run
    end
    
    result = values.to_a.first
    
    # create an object and return it
    Kilt::Object.new(result['type'], result)
  end
  
  # Get a list of objects
  # Returns: array of hashes
  # Example: Kilt.objects('events')
  # Used directly or via method_missing
  def self.get_collection(object_type)
    # connect to the db, get the date, close the connection, return the array
    results = Utils.db do
      r.db(Kilt.config.db.db).table('objects').filter({'type' => "#{object_type.singularize.to_s}"}).run
    end
    
    # create an object collection
    Kilt::ObjectCollection.new(results.to_a)
  end

  class << self
    private
    def slug_is_unique? slug
      results = r.db(Kilt.config.db.db).table('objects').filter({'slug' => "#{slug.to_s}"}).run
      results.to_a.length == 0
    end
  end

end

