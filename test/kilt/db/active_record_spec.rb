require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')

describe Kilt::DB::ActiveRecord do

  before do
    clear_out_the_database
  end

  describe "slug for" do
    it "should use the kilt slugger" do
      expected = Object.new
      object   = Object.new
      Kilt::Slugger.stubs(:slug_for).with(object).returns expected

      result = Kilt::DB::ActiveRecord.new.slug_for object
      result.must_be_same_as expected
    end
  end

end
