# if no activerecord, then this class makes no sense
if Object.const_defined? 'ActiveRecord'

  class KiltObject < ActiveRecord::Base
    serialize :data, Hash
  end

end
