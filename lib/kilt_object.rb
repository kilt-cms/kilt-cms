class KiltObject < ActiveRecord::Base
  serialize :data, Hash
end
