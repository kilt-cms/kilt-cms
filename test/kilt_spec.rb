require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do
      keys = default_test_config.objects.map { |k, _| k }
      Kilt.types.must_equal keys
    end

  end

  describe "creating an object" do

    let(:values) do
      {}
    end

    let(:object) do
      Kilt::Object.new('cat', values)
    end

    it "should be able to be called without throwing an error" do
      values['name'] = 'another test'
      Kilt.create object
    end

    it "should return a result" do
      values['name'] = 'another test'
      Kilt.create(object).must_equal true
    end

  end

end
