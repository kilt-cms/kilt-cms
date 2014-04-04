module Kilt

  class RethinkDbDatabase

    def initialize(options)
      @options = options
    end

    def find(slug)
      results = execute { slug_query(slug) }
      return nil unless results
      results = results.to_a
      return nil if results.first.is_a? Array
      results.first
    end

    def find_all_by_type type
      execute { type_query(type) }.to_a
    end

    def create(object)
      result = execute { objects_table.insert(object.values) }
      result['errors'] == 0
    end

    def update(object)
      result = execute do
        unique_id_query(object['unique_id']).update(object.values)
      end
      result['errors'] == 0
    end

    def delete(slug)
      result = execute { slug_query(slug).delete() }
      result['errors'] == 0
    end

    def delete_all
      execute do
        @r.db(Kilt.config.test.db.db).table('objects').delete()
      end
    end

    # Make a db call
    def execute(&block)
      setup_the_database
      #@db ||= r.connect(:host => @options[:host], :port => @options[:port]).repl
      block.call.run(@connection)
      #block.call
    end

    def setup!
      if @options[:host] && @options[:port]
        begin
          # See if the db exists and create it otherwise
          dbs = execute { @r.db_list }.to_a
          if !dbs.to_a.include? @options[:db]
            execute { @r.db_create(@options[:db]) }
          end

          # See if the table exists and create it otherwise
          tables = execute { @r.db(@options[:db]).table_list }.to_a
          if !tables.to_a.include? "objects"
            execute { @r.db(@options[:db]).table_create("objects", :primary_key => "unique_id") }
          end
        rescue
          raise Kilt::CantSetupDatabaseError
        end
      else
        raise Kilt::NoDatabaseConfigError
      end
    end

    private

    def setup_the_database
      unless @r && @connection
        begin
          @r = RethinkDB::RQL.new
          @connection = @r.connect(:host => @options[:host], :port => @options[:port], :db => @options[:db])
        rescue
          raise Kilt::CantConnectToDatabaseError
        end
      end
    end

    def objects_table
      setup_the_database
      @r.table('objects')
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
