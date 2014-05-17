module Kilt
  module Formatting
    def self.singular_name_of object
      type = if object.is_a? Symbol
               object
             else
               object.type
             end
      type.to_s.split('_').map { |x| x.capitalize }.join(' ')
    end
  end
end
