require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do
      key1, key2, key3 = 1, 2, 3

      config  = Object.new
      objects = { key1 => nil, key2 => nil, key3 => nil }

      config.stubs(:objects).returns objects
      Kilt.stubs(:config).returns config

      Kilt.types.must_equal ['1', '2', '3']
    end

  end

end
