module Kilt

  class Database

    def initialize(options)
      @options = options
    end

    def find(slug)
      results = Utils.db do
        slug_query(slug).limit(1).run
      end
      return nil unless results
      results = results.to_a
      return nil if results.first.is_a? Array
      results.first
    end

    def find_all_by_type type
      Utils.db do
        objects_table
          .filter({'type' => "#{type.singularize.to_s}"})
          .run
      end.to_a
    end

    def create(object)
      result = Utils.db do
        objects_table.insert(object.values).run
      end

      result['errors'] == 0
    end

    def update(object)
      result = Utils.db do
        objects_table
          .filter( { 'unique_id' => "#{object['unique_id']}" } )
          .update(object.values)
          .run
      end
      (result['errors'] == 0)
    end

    def delete(slug)
      result = Utils.db do
        slug_query(slug).delete().run
      end
      result['errors'] == 0
    end

    private

    def objects_table
      r.db(Kilt.config.db.db)
        .table('objects')
    end

    def slug_query(slug)
      objects_table.filter( { 'slug' => "#{slug}" } )
    end

  end

end
