require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')

describe Kilt::DB::ActiveRecordModel do

  before do
    clear_out_the_database
  end

  let(:database) { Kilt::DB::ActiveRecordModel.new Giraffe }

  it "should accept an AR model as a constructor argument" do
    Kilt::DB::ActiveRecordModel.new Giraffe
  end

  describe "find" do
    it "should allow the finding of an object by an id" do
      giraffe = Giraffe.create
      result = database.find giraffe.id
      result.id.must_equal giraffe.id
    end
  end

  describe "find all by type" do

    it "should return nothing all of the records" do
      all_the_giraffes = Object.new
      Giraffe.stubs(:all).returns all_the_giraffes
      result = database.find_all_by_type nil
      result.must_be_same_as all_the_giraffes
    end

  end

  describe "create" do

    it "should create a new record" do
      data = {}
      database.create data
      Giraffe.count.must_equal 1
    end

    it "should assign the properties" do
      data = { 
               first_name: SecureRandom.uuid,
               last_name:  SecureRandom.uuid,
               city:       SecureRandom.uuid,
               state:      SecureRandom.uuid,
               height:     SecureRandom.uuid,
             }
      database.create data
      Giraffe.first.first_name.must_equal data[:first_name]
      Giraffe.first.last_name.must_equal data[:last_name]
      Giraffe.first.city.must_equal data[:city]
      Giraffe.first.state.must_equal data[:state]
      Giraffe.first.height.must_equal data[:height]
    end

    it "should ignore properties not on the model" do
      data = { 
               something_else: SecureRandom.uuid,
               first_name:     SecureRandom.uuid,
             }
      database.create data
      Giraffe.first.first_name.must_equal data[:first_name]
    end

    it "should return true properties not on the model" do
      data = { 
               first_name:     SecureRandom.uuid,
             }
      database.create(data).must_equal true
    end

    it "should use the save method that throws an error" do
      data = { 
               first_name:     SecureRandom.uuid,
             }
      Giraffe.any_instance.expects(:save!)
      database.create(data)
    end

    describe "an error is thrown when saving the model" do
      it "should return false" do
        data = { 
                 first_name:     SecureRandom.uuid,
               }
        Giraffe.any_instance.expects(:save!).raises 'k'
        database.create(data).must_equal false
      end
    end

  end

  describe "update" do

    describe "provided a block of data for a record that exists" do

      let(:giraffe) { Giraffe.create }
      let(:data)    { { 'unique_id' => giraffe.id } }

      it "should update the reord" do
        data['first_name'] = SecureRandom.uuid
        data['last_name']  = SecureRandom.uuid
        data['city']       = SecureRandom.uuid
        data['state']      = SecureRandom.uuid
        data['height']     = SecureRandom.uuid
        database.update data
        result = Giraffe.find giraffe.id
        result.first_name.must_equal data['first_name']
        result.last_name.must_equal data['last_name']
        result.city.must_equal data['city']
        result.state.must_equal data['state']
        result.height.must_equal data['height']
      end

      it "should return true" do
        data['first_name'] = SecureRandom.uuid
        result = database.update data
        result.must_equal true
      end

      it "should use the save method that throws on errors" do
        Giraffe.any_instance.expects(:save!)
        database.update data
      end

      describe "and an error occurs during the save" do
        it "should return false" do
          Giraffe.any_instance.stubs(:save!).raises 'k'
          result = database.update data
          result.must_equal false
        end
      end

    end

    describe "provided a block of data for a record that DOES NOT exist" do
      let(:giraffe) { Giraffe.create }
      let(:data)    { { 'unique_id' => giraffe.id + 1 } }

      it "should return false" do
        result = database.update data
        result.must_equal false
      end

    end

  end

end
