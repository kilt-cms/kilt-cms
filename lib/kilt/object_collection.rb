require 'forwardable'

module Kilt
  class ObjectCollection
    include Enumerable
    extend Forwardable
    attr_accessor :values
    
    def_delegators :@values, :each, :<<
    
    def initialize(values = [])
      @values = values
    end
    
    def [](key)
      @values[key]
    end
    
    def order(key = 'name', direction = 'ASC')
      @values = @values.sort_by { |hash| hash[key] }
      direction == 'DESC' ? @values.reverse! : values
      return self
    end
    
    def group(key)
      # create an empty hash
      ret = {}
      
      # loop through all items in @values
      @values.each do |object|
        # for each item, check to see if the hash already has a value for this key
        if ret[object[key]]
          # if it does, add it to the value, which should be an array
          a = ret[object[key]]
          a << object
        else
          # if it doesn't, create an array first, add this loop item to it, and add the 
          # array as the value for that hash key
          a = []
          a << object
          ret[object[key]] = a
        end
      end
      
      # return the hash
      ret
    end
    
    def empty?
      @values.empty?
    end
  end
end