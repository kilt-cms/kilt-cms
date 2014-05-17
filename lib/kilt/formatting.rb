module Kilt
  module Formatting
    def self.singular_name_of object
      type = if object.is_a? Symbol
               object.to_s
             elsif object.is_a? String
               object
             else
               object.type.to_s
             end
      type.split('_').map { |x| x.capitalize }.join(' ')
    end
  end
end
