module Kilt
  class ActiveRecordDatabase

    def find(slug)
      thing = KiltObject.where(slug: slug).first
      return nil unless thing
      thing.data
    end

    def find_all_by_type type
      things = KiltObject.where(object_type: "#{type.singularize.to_s}")
      things.map { |x| x.data }
    end

    def create(object)
      KiltObject.create!(unique_id:   object['id'],
                         slug:        object['slug'],
                         object_type: object['type'],
                         data:        object.values)
      true
    rescue
      false
    end

    def update(object)
      thing = KiltObject.where(unique_id: object['id']).first
      return false unless thing
      thing.slug = object['slug']
      thing.data = object.values
      thing.save
    end

    def delete(slug)
      thing = KiltObject.where(slug: slug).first
      thing.delete if thing
      true
    rescue
      false
    end

  end

end
