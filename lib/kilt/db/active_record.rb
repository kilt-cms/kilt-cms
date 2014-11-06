module Kilt

  module DB

    class ActiveRecord

      def find(slug)
        object = KiltObject.where(slug: slug).first
        object ? object.data : nil
      end

      def find_all_by_type type
        KiltObject.where(object_type: "#{type.singularize.to_s}")
                  .map { |x| x.data }
      end

      def create(object)
        KiltObject.create!(unique_id:   object['unique_id'],
                           slug:        object['slug'],
                           object_type: object['type'],
                           data:        object.values)
        true
      rescue
        false
      end

      def update(current)
        object = KiltObject.where(unique_id: current['unique_id']).first
        return false unless object
        object.slug = current['slug']
        object.data = current.values
        object.save
      end

      def delete(slug)
        object = KiltObject.where(slug: slug).first
        object.delete if object
        true
      rescue
        false
      end

      def setup!
      end

      def slug_for object
        Slugger.slug_for object
      end

    end

  end

end
