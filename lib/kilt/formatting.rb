module Kilt
  module Formatting
    def self.singular_name_of object
      object.type.to_s.split('_').map { |x| x.capitalize }.join(' ')
    end
  end
end
