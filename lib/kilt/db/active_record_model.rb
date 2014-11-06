module Kilt

  module DB

    class ActiveRecordModel

      attr_reader :model

      def initialize model
        @model = model
      end

      def find id
        type, id = id.to_s.split('_')
        return nil unless type == model.to_s.underscore
        record = find_this_record id
        record ? convert_to_json(record) : nil
      end

      def find_all_by_type _
        model.all.map { |r| convert_to_json r }
      end

      def create data
        record = model.new
        update_record_with_this_data record, data
        record.save!
      rescue
        false
      end

      def update data
        record = find_this_record data['unique_id']
        return false unless record
        update_record_with_this_data record, data
        record.save!
      rescue
        false
      end

      def delete id
        record = find_this_record id
        return false unless record
        record.delete
        true
      end

      def slug_for object
        "#{model.to_s.underscore}_#{object['unique_id']}"
      end

      private

      def find_this_record id
        model.where(id: id).first
      end

      def convert_to_json record
        data = JSON.parse(record.to_json).merge( 'unique_id' => record.id )
        data['slug'] = slug_for data
        data
      end

      def update_record_with_this_data record, data
        data.each { |k, v| set_record_attribute record, k, v }
      end

      def set_record_attribute record, key, value
        record.send("#{key}=".to_sym, value)
      rescue
      end

    end

  end

end
