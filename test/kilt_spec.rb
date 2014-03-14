require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  before do
    # This makes random Socket errors go away.
    # I think the test are either running very fast
    # or they concurrently... slowing them down
    # seems to stop socket errors from popping up
    # in the block passed to Utils.db.
    sleep(0.05)

    clear_out_the_database
  end

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do
      keys = default_test_config.objects.map { |k, _| k }
      Kilt.types.must_equal keys
    end

  end

  describe "creating an object" do

    [
      ['1/1/2014', 'cat', 'Apple',  '1388556000000', 'apple' ],
      ['2/2/2016', 'dog', 'Orange', '1454392800000', 'orange'],
    ].map do |values|
      Struct.new(:today, :type, :name, :unique_id, :slug).new *values
    end.each do |scenario|

      describe "basic scenarios" do

        let(:values) { {} }

        let(:object) do
          Kilt::Object.new(scenario.type, values)
        end

        before do
          Timecop.freeze Time.parse(scenario.today)
          values['name'] = scenario.name
        end

        it "should set a unique id based on time" do
          Kilt.create(object)
          object['unique_id'].must_equal scenario.unique_id
        end

        it "should set the name" do
          Kilt.create(object)
          object['name'].must_equal scenario.name
        end

        it "should create an object that can be retrieved out of the database again" do
          Kilt.create(object)
          fresh = Kilt.get(object['slug'])
          fresh['unique_id'].must_equal object['unique_id']
        end

        it "should set the type of the object" do
          Kilt.create(object)
          object['type'].must_equal scenario.type
          Kilt.get(object['slug'])['type'].must_equal scenario.type
        end

        it "should set the created_at" do
          Kilt.create(object)
          object['created_at'].must_equal Time.parse(scenario.today)
          Kilt.get(object['slug'])['created_at'].must_equal Time.parse(scenario.today)
        end

        it "should set the updated_at" do
          Kilt.create(object)
          object['updated_at'].must_equal Time.parse(scenario.today)
          Kilt.get(object['slug'])['updated_at'].must_equal Time.parse(scenario.today)
        end

        it "should set a slug on the object" do
          Kilt.create(object)
          object['slug'].must_equal scenario.slug
        end

        describe "creating the record twice" do

          it "should keep the slugs unique by appending the id to the second record" do

            first  = Kilt::Object.new(scenario.type, values)
            second = Kilt::Object.new(scenario.type, values.clone)

            Kilt.create(first)
            sleep(0.05)
            Kilt.create(second)

            first['slug'].must_equal scenario.slug
            second['slug'].must_equal "#{scenario.slug}-#{scenario.unique_id}"

          end

        end

      end

    end

  end

end

