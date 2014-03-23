module Kilt

  class Database

    def initialize(options)
      @options = options
    end

    def find(slug)
      results = execute { slug_query(slug).limit(1).run }
      return nil unless results
      results = results.to_a
      return nil if results.first.is_a? Array
      results.first
    end

    def find_all_by_type type
      execute { type_query(type).run }.to_a
    end

    def create(object)
      result = execute { objects_table.insert(object.values).run }
      result['errors'] == 0
    end

    def update(object)
      result = execute do
        unique_id_query(object['unique_id']).update(object.values).run
      end
      result['errors'] == 0
    end

    def delete(slug)
      result = execute { slug_query(slug).delete().run }
      result['errors'] == 0
    end

    # Make a db call
    def execute(&block)
      @db ||= r.connect(:host => @options[:host], :port => @options[:port]).repl
      block.call
    end

    def self.setup!
      if Kilt.config.db.host && Kilt.config.db.port
        begin
          db = r.connect(:host => Kilt.config.db.host, :port => Kilt.config.db.port).repl
        rescue
          raise Kilt::CantConnectToDatabaseError
        end

        begin
          #
          # See if the db exists and create it otherwise
          dbs = r.db_list.run
          if !dbs.to_a.include? Kilt.config.db.db
            r.db_create(Kilt.config.db.db).run
          end
          #
          # See if the table exists and create it otherwise
          tables = r.db(Kilt.config.db.db).table_list.run
          if !tables.to_a.include? "objects"
            r.db(Kilt.config.db.db).table_create("objects", :primary_key => "unique_id").run
          end

        rescue
          raise Kilt::CantSetupDatabaseError
        ensure
          db.close
        end

      else
        raise Kilt::NoDatabaseConfigError
      end
    end

    private

    def objects_table
      r.db(Kilt.config.db.db).table('objects')
    end

    def slug_query(slug)
      objects_table.filter( { 'slug' => "#{slug}" } )
    end

    def type_query(type)
      objects_table.filter( {'type' => "#{type.singularize.to_s}" } )
    end

    def unique_id_query(unique_id)
      objects_table.filter( { 'unique_id' => "#{unique_id}" } )
    end

  end

end
