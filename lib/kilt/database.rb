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
      results.to_a.first
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

    def slug_is_unique? slug
      find(slug).nil?
    end

  end

end
