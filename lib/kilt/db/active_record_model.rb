module Kilt

  module DB

    class ActiveRecordModel

      attr_reader :model

      def initialize model
        @model = model
      end

      def find id
        convert_to_json model.find(id)
      end

      def find_all_by_type _
        model.all.map { |r| convert_to_json r }
      end

      def create data
        record = model.new
        data.each do |k, v|
          begin
            record.send("#{k}=".to_sym, v)
          rescue
          end
        end
        record.save!
      rescue
        false
      end

      def update data
        record = model.where(id: data['unique_id']).first
        return false unless record
        data.each do |k, v|
          begin
            record.send("#{k}=".to_sym, v)
          rescue
          end
        end
        record.save!
      rescue
        false
      end

      def delete id
        record = model.where(id: id).first
        return false unless record
        record.delete
        true
      end

      private

      def convert_to_json record
        JSON.parse(record.to_json).merge( 'unique_id' => record.id )
      end

    end

  end

end
