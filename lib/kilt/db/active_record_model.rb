module Kilt
  module DB
    class ActiveRecordModel
      def initialize model
      end

      def find id
        Giraffe.find id
      end

      def find_all_by_type _
        Giraffe.all
      end
    end
  end
end
