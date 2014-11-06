require "kilt/base"
require_relative "kilt_object"
require_relative "kilt_view_model"

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
    object['type']       = object.type

    database = Utils.database_for(object['type'])
    object['slug'] = database.slug_for object
    database.create object
  end

  # Update an object
  # Returns: boolean
  # Example: Kilt.update(object)
  def self.update(slug, object)
    database = Utils.database_for(object['type'])
    object['updated_at'] = Time.now
    object['slug']       = database.slug_for object

    database.update object
  end

  # Delete an object
  # Returns: boolean
  # Example: Kilt.delete('some-object')
  def self.delete(slug)
    Utils.databases.first.delete slug
  end

  # Get the content for a specific object
  # Returns: Kilt::Object instance
  # Example: Kilt.object('big-event')
  def self.get(slug)
    data = look_in_all_databases_for slug
    data ? Kilt::Object.new(data['type'], data) : nil
  end
  
  # Get a list of objects
  # Returns: array of hashes
  # Example: Kilt.objects('events')
  # Used directly or via method_missing
  def self.get_collection(object_type)
    results = Utils.database_for(object_type).find_all_by_type object_type
    Kilt::ObjectCollection.new results
  end

  # Get every field type used
  # Returns: Array of strings
  # Example: Kilt.all_used_fields
  def self.all_used_fields
    used_field_types = Kilt.config[:objects].map do |object|
                         object.map do |config|
                           begin
                             config[:fields].map { |_, v| v }
                           rescue
                             nil
                           end
                         end
                       end.flatten
    used_field_types.select { |x| x }.group_by { |x| x }.map { |x| x[0] }
  end

  class << self
    private
    def look_in_all_databases_for slug
      Utils.databases.each do |database|
        object = database.find slug
        return object if object
      end
      nil
    end
  end

end
