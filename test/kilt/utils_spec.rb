require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Utils do

  describe "setting up the database" do
    it "should call setup on the current database" do

      database = Object.new
      Kilt::Utils.stubs(:database).returns database

      database.expects(:setup!)

      Kilt::Utils.setup_db
        
    end
  end

  describe "database" do

    ['test', 'development', 'production'].each do |environment|

      describe "when current environment is #{environment}" do

        before do
          Kilt::Utils.instance_eval { @database = nil }
          ENV.stubs(:[]).with('RAILS_ENV').returns environment
        end

        after { Kilt::Utils.instance_eval { @database = nil } }

        it "should return a new Kilt database" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(environment.to_sym).returns Object.new
          Kilt.config[environment.to_sym].stubs(:db).returns Object.new

          Kilt::RethinkDbDatabase.stubs(:new)
                                 .with(Kilt.config[environment.to_sym].db)
                                 .returns database

          Kilt::Utils.database.must_be_same_as database

        end

        it "should return the same Kilt database everytime it is called" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(environment.to_sym).returns Object.new
          Kilt.config[environment.to_sym].stubs(:db).returns Object.new

          Kilt::RethinkDbDatabase.expects(:new)
                                 .with(Kilt.config[environment.to_sym].db)
                                 .returns database

          Kilt::Utils.database.must_be_same_as Kilt::Utils.database

        end

        describe "when config is done the old Kilt way, with a single 'db'" do

          it "should return a new Kilt database with the development config" do

            database  = Object.new

            Kilt.stubs(:config).returns Object.new
            Kilt.config.stubs(:db).returns Object.new

            Kilt::RethinkDbDatabase.stubs(:new)
                                   .with(Kilt.config.db)
                                   .returns database

            Kilt::Utils.database.must_be_same_as database

          end

        end

      end

    end

    ['', nil].each do |environment|

      describe "when current environment is #{environment}" do

        before do
          Kilt::Utils.instance_eval { @database = nil }
          ENV.stubs(:[]).with('RAILS_ENV').returns environment
        end

        after { Kilt::Utils.instance_eval { @database = nil } }

        it "should return a new Kilt database with the development config" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(:development).returns Object.new
          Kilt.config[:development].stubs(:db).returns Object.new

          Kilt::RethinkDbDatabase.stubs(:new)
                                 .with(Kilt.config[:development].db)
                                 .returns database

          Kilt::Utils.database.must_be_same_as database

        end

      end

    end

  end

end
