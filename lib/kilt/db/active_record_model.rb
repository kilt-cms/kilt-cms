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

      def create data
        giraffe = Giraffe.new
        data.each do |k, v|
          begin
            giraffe.send("#{k}=".to_sym, v)
          rescue
          end
        end
        giraffe.save!
      rescue
        false
      end
    end
  end
end
