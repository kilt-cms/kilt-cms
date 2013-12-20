require 'spec_helper'

describe Kilt do
  it "should exist" do
    Kilt.should be
  end
end

describe Kilt.config do
  it "should be found" do
    Kilt.config.should be
  end
end

describe Kilt.types do
  it "should exist" do
    Kilt.types.should be
  end
  it "should have at least one object" do
    Kilt.types.count.should be > 0
  end
  it "should have the same number of types as found in the config" do
    Kilt.types.count.should eq(Kilt.config.objects.count)
  end
end

describe Kilt.slkjfklsjdflksjdf do
  it "should return nil if non-existent method called" do
    Kilt.slkjfklsjdflksjdf.should be_nil
  end
end
