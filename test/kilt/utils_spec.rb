require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Utils do

  describe "database" do

    describe "when current environment is test" do

      describe "and is called once" do

        before { Kilt::Utils.instance_eval { @database = nil } }

        it "should return a new Kilt database" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:test).returns Object.new
          Kilt.config.test.stubs(:db).returns Object.new

          Kilt::Database.stubs(:new).with(Kilt.config.test.db).returns database
          Kilt::Utils.database.must_be_same_as database

        end

      end

    end

  end

end
