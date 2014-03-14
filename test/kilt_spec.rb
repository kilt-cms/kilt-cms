require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  before do
    clear_out_the_database
  end

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do
      keys = default_test_config.objects.map { |k, _| k }
      Kilt.types.must_equal keys
    end

  end

  [
    ['1/1/2014', 'cat', 'Apple',  '1388556000000', 'apple' ],
    ['2/2/2016', 'dog', 'Orange', '1454392800000', 'orange'],
  ].map do |values|
    Struct.new(:today, :type, :name, :unique_id, :slug).new *values
  end.each do |scenario|

    describe "creating an object" do

      let(:values) do
        {}
      end

      let(:object) do
        Kilt::Object.new(scenario.type, values)
      end

      before do
        Timecop.freeze Time.parse(scenario.today)
        values['name'] = scenario.name
      end

      it "should return true" do
        Kilt.create(object).must_equal true
      end

      it "should set a unique id based on time" do
        Kilt.create(object)
        object['unique_id'].must_equal scenario.unique_id
      end

      it "should set the type of the object" do
        Kilt.create(object)
        object['type'].must_equal scenario.type
      end

      it "should set a slug on the object" do
        Kilt.create(object)
        object['slug'].must_equal scenario.slug
      end

    end

  end

end
