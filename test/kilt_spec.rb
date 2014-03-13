require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  describe "types" do

    it "should return the keys from the objects in the Kilt config" do

      keys = default_test_config.objects.map { |k, _| k }

      Kilt.types.must_equal keys

    end

  end

end
