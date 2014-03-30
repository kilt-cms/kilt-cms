require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe KiltObject do

  before do
    clear_out_the_database
  end

  it "should exist" do
    KiltObject.delete_all
  end
end
