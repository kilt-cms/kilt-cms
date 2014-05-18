module Kilt

  module Formatting

    def self.singular_name_of object
      simple_name_of(object)
        .split('_')
        .map { |x| x.capitalize }
        .join(' ')
    end

    def self.plural_name_of object
      singular_name_of(object).pluralize
    end

    class << self

      private

      def simple_name_of object
        type = if object.is_a? Symbol
                 object.to_s
               elsif object.is_a? String
                 object
               else
                 object.type.to_s
               end

        name_of_type_in_config(type) || type
      end

      def name_of_type_in_config type
        kilt_type = Kilt.send(type)
        return nil unless kilt_type
        kilt_type['name']
      end
    end
  end
end
