module Kilt
  module Formatting
    def self.singular_name_of object
      the_type_of(object)
        .split('_')
        .map { |x| x.capitalize }
        .join(' ')
    end

    def self.plural_name_of object
      singular_name_of(object).pluralize
    end

    class << self

      private

      def the_type_of object
        if object.is_a? Symbol
          object.to_s
        elsif object.is_a? String
          object
        else
          object.type.to_s
        end
      end
    end
  end
end
