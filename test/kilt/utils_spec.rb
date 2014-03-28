require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Utils do

  describe "database" do

    ['test', 'development', 'production'].each do |environment|

      describe "when current environment is #{environment}" do

        before do
          Kilt::Utils.instance_eval { @database = nil }
          ENV.stubs(:[]).with('RAILS_ENV').returns environment
        end

        it "should return a new Kilt database" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(environment.to_sym).returns Object.new
          Kilt.config.send(environment.to_sym).stubs(:db).returns Object.new

          Kilt::Database.stubs(:new)
                        .with(Kilt.config.send(environment.to_sym).db)
                        .returns database

          Kilt::Utils.database.must_be_same_as database

        end

        it "should return the same Kilt database everytime it is called" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(environment.to_sym).returns Object.new
          Kilt.config.send(environment.to_sym).stubs(:db).returns Object.new

          Kilt::Database.expects(:new)
                        .with(Kilt.config.send(environment.to_sym).db)
                        .returns database

          Kilt::Utils.database.must_be_same_as Kilt::Utils.database

        end

        describe "when config is done the old Kilt way, with a single 'db'" do

          it "should return a new Kilt database with the development config" do

            database  = Object.new

            Kilt.stubs(:config).returns Object.new
            Kilt.config.stubs(:db).returns Object.new

            Kilt::Database.stubs(:new)
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

        it "should return a new Kilt database with the development config" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:development).returns Object.new
          Kilt.config.send(:development).stubs(:db).returns Object.new

          Kilt::Database.stubs(:new)
                        .with(Kilt.config.send(:development).db)
                        .returns database

          Kilt::Utils.database.must_be_same_as database

        end

      end

    end

  end

end
