module Kilt

  class Database

    def initialize(options)
      @options = options
    end

    def create(object)
      result = Utils.db do
        r.db(Kilt.config.db.db).table('objects').insert(object.values).run
      end

      result['errors'] == 0
    end

    def slug_is_unique? slug
      Utils.db do
        r.db(Kilt.config.db.db).table('objects')
                               .filter( { 'slug' => "#{slug}" } )
                               .run
      end.to_a.length == 0
    end

  end

end
