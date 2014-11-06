require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Utils do

  describe "setting up the database" do
    it "should call setup on the current database" do

      database = Object.new
      Kilt::Utils.stubs(:database_for).with(nil).returns database

      database.expects(:setup!)

      Kilt::Utils.setup_db

    end
  end

  describe "database" do

    ['test', 'development', 'production'].each do |environment|

      describe "when current environment is #{environment}" do

        before do
          Kilt::Utils.instance_eval { @database = nil; @db_type = nil }
          ENV.stubs(:[]).with('RAILS_ENV').returns environment
        end

        after { Kilt::Utils.instance_eval { @database = nil; @db_type = nil } }

        it "should return a new Kilt database" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(environment.to_sym).returns Object.new
          Kilt.config[environment.to_sym].stubs(:[]).with(:db).returns Object.new

          Kilt::DB::ActiveRecord.stubs(:new).returns database

          Kilt::Utils.database_for(nil).must_be_same_as database

        end

        it "should return the same Kilt database everytime it is called" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(environment.to_sym).returns Object.new
          Kilt.config[environment.to_sym].stubs(:[]).with(:db).returns Object.new

          Kilt::DB::ActiveRecord.stubs(:new).returns database

          Kilt::Utils.database_for(nil).must_be_same_as Kilt::Utils.database_for(nil)

        end

        describe "when config is done the old Kilt way, with a single 'db'" do

          it "should return a new Kilt database with the development config" do

            database  = Object.new

            Kilt.stubs(:config).returns Object.new
            Kilt.config.stubs(:[]).returns nil
            Kilt.config.stubs(:[]).with(:db).returns Object.new

            Kilt::DB::ActiveRecord.stubs(:new).returns database

            Kilt::Utils.database_for(nil).must_be_same_as database

          end

        end

      end

    end

    ['', nil].each do |environment|

      describe "when current environment is #{environment}" do

        before do
          Kilt::Utils.instance_eval { @database = nil; @db_type = nil }
          ENV.stubs(:[]).with('RAILS_ENV').returns environment
        end

        after { Kilt::Utils.instance_eval { @database = nil; @db_type = nil } }

        it "should return a new Kilt database with the development config" do

          database  = Object.new

          Kilt.stubs(:config).returns Object.new
          Kilt.config.stubs(:[]).with(:development).returns Object.new
          Kilt.config[:development].stubs(:[]).with(:db).returns Object.new

          Kilt::DB::ActiveRecord.stubs(:new).returns database

          Kilt::Utils.database_for(nil).must_be_same_as database

        end

      end

    end

  end

  describe "slugify a string" do
    it "should replace spaces with dashes" do
      Kilt::Utils.slugify("this works").must_equal "this-works"
    end
    it "should remove apostrophes" do
      Kilt::Utils.slugify("this's working").must_equal "thiss-working"
    end
    it "should replace @ and & with at and and" do
      Kilt::Utils.slugify("hands @ two & ten").must_equal "hands-at-two-and-ten"
    end
    it "should replace all non alphanumeric characters with dash" do
      Kilt::Utils.slugify("a!b@c#d$e%f^g&h*i(j)k_l.m,n<o>p[q]r/s|t?u;v~w{x}y+z").must_equal "a-b-at-c-d-e-f-g-and-h-i-j-k-l-m-n-o-p-q-r-s-t-u-v-w-x-y-z"
    end
    it "should replace periods and underscores with dashes" do
      Kilt::Utils.slugify("this_works.now").must_equal "this-works-now"
    end
    it "should convert double dash to single" do
      Kilt::Utils.slugify("this--works").must_equal "this-works"
    end
    it "should strip leading and trailing dashes" do
      Kilt::Utils.slugify("-this-works-").must_equal "this-works"
    end
    it "should downcase the string" do
      Kilt::Utils.slugify("THIS WORKS").must_equal "this-works"
    end
  end

  describe "different databases for different types" do

    after do
      Kilt::Utils.instance_eval do
        @special_types = nil
      end
    end

    describe "if a new database is registered for one type" do

      [
        [:cat,    :dog],
        [:dog,    :cat],
        [Giraffe, :cat],
      ].map { |x| Struct.new(:special, :regular).new(*x) }.each do |example|

        describe "multiple examples" do

          let(:special_database) { Object.new }

          describe "getting the database back out" do
            it "should use the new database for #{example.special}" do
              Kilt::Utils.register_database_for(example.special) { special_database }
              database = Kilt::Utils.database_for example.special
              database.must_be_same_as special_database
            end

            it "should allow retrieval with a string #{example.special}" do
              symbol = example.special.to_s.underscore
              Kilt::Utils.register_database_for(example.special) { special_database }
              database = Kilt::Utils.database_for symbol
              database.must_be_same_as special_database
            end

            it "should allow retrieval with a symbol #{example.special}" do
              symbol = example.special.to_s.underscore.to_sym
              Kilt::Utils.register_database_for(example.special) { special_database }
              database = Kilt::Utils.database_for symbol
              database.must_be_same_as special_database
            end
          end

          it "should still use the old database for dog" do
            Kilt::Utils.register_database_for(example.special) { special_database }
            database = Kilt::Utils.database_for example.regular
            database.wont_be_same_as special_database
          end

          it "should not call the database block if the database is not requested" do
            Kilt::Utils.register_database_for(example.special) { raise 'k' }
          end

        end

      end

    end

    describe "if a new database is registered for two types" do

      let(:cat_database) { Object.new }
      let(:dog_database) { Object.new }

      before do
        Kilt::Utils.register_database_for(:cat) do
          cat_database
        end

        Kilt::Utils.register_database_for(:dog) do
          cat_database
        end
      end

      it "should use the cat database for cats" do
        database = Kilt::Utils.database_for :cat
        database.must_be_same_as cat_database
      end

      it "should use the dog database for dogs" do
        database = Kilt::Utils.database_for :dog
        database.wont_be_same_as dog_database
      end

    end

  end

  describe "databases" do

    let(:default_database) { Object.new }

    before do
      Kilt::Utils.instance_eval { @special_types = nil }
      Kilt::Utils.stubs(:database_for).with(nil).returns default_database
    end

    after { Kilt::Utils.instance_eval { @special_types = nil } }

    it "should return one database" do
      Kilt::Utils.databases.count.must_equal 1
    end

    it "should start with the default database (database_for nil)" do
      Kilt::Utils.databases.first.must_be_same_as default_database
    end

    describe "and I registered a database" do

      let(:second_database) { Object.new }

      before do
        key = SecureRandom.uuid.underscore
        Kilt::Utils.register_database_for(key) { second_database }
        Kilt::Utils.stubs(:database_for).with(key).returns second_database
      end

      it "should have 2 databases" do
        Kilt::Utils.databases.count.must_equal 2
      end

      it "should bring the default database up first" do
        Kilt::Utils.databases[0].must_be_same_as default_database
      end

      it "should return the special database second" do
        Kilt::Utils.databases[1].must_be_same_as second_database
      end

      describe "and I registered a third database" do

        let(:third_database) { Object.new }

        before do
          key = SecureRandom.uuid.underscore
          Kilt::Utils.register_database_for(key) { third_database }
          Kilt::Utils.stubs(:database_for).with(key).returns third_database
        end

        it "should have 3 databases" do
          Kilt::Utils.databases.count.must_equal 3
        end

        it "should bring the default database up first" do
          Kilt::Utils.databases[0].must_be_same_as default_database
        end

        it "should return the second database second" do
          Kilt::Utils.databases[1].must_be_same_as second_database
        end

        it "should return the third database third" do
          Kilt::Utils.databases[2].must_be_same_as third_database
        end

      end

    end

  end

end
