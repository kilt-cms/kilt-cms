module Kilt

  class Database

    def initialize(options)
      @options = options
    end

    def find(slug)
      results = Utils.db do
        r.db(Kilt.config.db.db)
          .table('objects')
          .filter( {'slug' => "#{slug}" } )
          .limit(1)
          .run
      end
      return nil unless results
      results = results.to_a
      return nil if results.first.is_a? Array
      results.first
    end

    def find_all_by_type type
      Utils.db do
        r.db(Kilt.config.db.db)
          .table('objects')
          .filter({'type' => "#{type.singularize.to_s}"})
          .run
      end.to_a
    end

    def create(object)
      result = Utils.db do
        r.db(Kilt.config.db.db).table('objects').insert(object.values).run
      end

      result['errors'] == 0
    end

    def update(object)
      result = Utils.db do
        r.db(Kilt.config.db.db)
          .table('objects')
          .filter( { 'unique_id' => "#{object['unique_id']}" } )
          .update(object.values)
          .run
      end
      (result['errors'] == 0)
    end

    def delete(slug)
      result = Utils.db do
        r.db(Kilt.config.db.db)
          .table('objects')
          .filter( { 'slug' => "#{slug.to_s}" } )
          .delete()
          .run
      end
      result['errors'] == 0
    end

  end

end
