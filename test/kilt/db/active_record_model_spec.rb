require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')

describe Kilt::DB::ActiveRecordModel do

  before do
    clear_out_the_database
  end

  it "should accept an AR model as a constructor argument" do
    Kilt::DB::ActiveRecordModel.new Giraffe
  end

  describe "find" do
    it "should allow the finding of an object by an id" do
      giraffe = Giraffe.create
      database = Kilt::DB::ActiveRecordModel.new Giraffe
      result = database.find giraffe.id
      result.id.must_equal giraffe.id
    end
  end

  describe "find all by type" do

    it "should return nothing all of the records" do
      all_the_giraffes = Object.new
      Giraffe.stubs(:all).returns all_the_giraffes
      database = Kilt::DB::ActiveRecordModel.new Giraffe
      result = database.find_all_by_type nil
      result.must_be_same_as all_the_giraffes
    end

  end

end
