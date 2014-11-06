require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')

describe Kilt::DB::ActiveRecordModel do

  before do
    clear_out_the_database
  end


  [Giraffe, Tiger].each do |model|

    describe "working against multiple models (#{model})" do

      let(:database) { Kilt::DB::ActiveRecordModel.new model }

      it "should accept an AR model as a constructor argument" do
        Kilt::DB::ActiveRecordModel.new model
      end

      describe "model" do
        it "should return the model" do
          database.model.must_equal model
        end
      end

      describe "slug for" do
        it "should return nil" do
          database.slug_for(nil).nil?.must_equal true
        end
      end

      describe "find" do

        describe "when the record exists" do

          it "should allow the finding of an object by an id" do
            giraffe = model.create
            result = database.find giraffe.id
            result['id'].must_equal giraffe.id
          end

          it "should return the jsonified data of the object in question" do
            giraffe = Struct.new(:id).new(Object.new)
            json    = Object.new
            data    = { SecureRandom.uuid => SecureRandom.uuid }

            giraffe.stubs(:to_json).returns json
            JSON.stubs(:parse).with(json).returns data
            model.stubs(:where).with(id: giraffe.id).returns [giraffe]

            result = database.find giraffe.id
            result[data.first[0]].must_be_same_as data.first[1]
          end

          it "should set the unique id to be the id of the record" do
            giraffe = model.create
            result = database.find giraffe.id
            result['unique_id'].must_equal giraffe.id
          end

          it "should set the slug" do
            giraffe = model.create

            slug    = Object.new
            database.stubs(:slug_for).with do |data|
              data['unique_id'] == giraffe.id
            end.returns slug

            result = database.find giraffe.id
            result['slug'].must_be_same_as slug
          end

        end

        describe "when the record does not exist" do
          it "should return nil" do
            result = database.find 1
            result.nil?.must_equal true
          end
        end

      end

      describe "find all by type" do

        it "should return all of the records" do
          all_the_giraffes = [model.create, model.create, model.create]
          result = database.find_all_by_type nil
          result.count.must_equal 3
        end

        it "should return hashes for each record" do
          all_the_giraffes = [model.create, model.create, model.create]
          result = database.find_all_by_type nil
          result[0]['unique_id'].must_equal all_the_giraffes[0].id
          result[1]['unique_id'].must_equal all_the_giraffes[1].id
          result[2]['unique_id'].must_equal all_the_giraffes[2].id
        end

      end

      describe "create" do

        it "should create a new record" do
          data = {}
          database.create data
          model.count.must_equal 1
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
          model.first.first_name.must_equal data[:first_name]
          model.first.last_name.must_equal data[:last_name]
          model.first.city.must_equal data[:city]
          model.first.state.must_equal data[:state]
          model.first.height.must_equal data[:height]
        end

        it "should ignore properties not on the model" do
          data = { 
                   something_else: SecureRandom.uuid,
                   first_name:     SecureRandom.uuid,
                 }
          database.create data
          model.first.first_name.must_equal data[:first_name]
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
          model.any_instance.expects(:save!)
          database.create(data)
        end

        describe "an error is thrown when saving the model" do
          it "should return false" do
            data = { 
                     first_name:     SecureRandom.uuid,
                   }
            model.any_instance.expects(:save!).raises 'k'
            database.create(data).must_equal false
          end
        end

      end

      describe "update" do

        describe "provided a block of data for a record that exists" do

          let(:giraffe) { model.create }
          let(:data)    { { 'unique_id' => giraffe.id } }

          it "should update the reord" do
            data['first_name'] = SecureRandom.uuid
            data['last_name']  = SecureRandom.uuid
            data['city']       = SecureRandom.uuid
            data['state']      = SecureRandom.uuid
            data['height']     = SecureRandom.uuid
            database.update data
            result = model.find giraffe.id
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
            model.any_instance.expects(:save!)
            database.update data
          end

          describe "and an error occurs during the save" do
            it "should return false" do
              model.any_instance.stubs(:save!).raises 'k'
              result = database.update data
              result.must_equal false
            end
          end

        end

        describe "provided a block of data for a record that DOES NOT exist" do
          let(:giraffe) { model.create }
          let(:data)    { { 'unique_id' => giraffe.id + 1 } }

          it "should return false" do
            result = database.update data
            result.must_equal false
          end

        end

      end

      describe "delete" do

        describe "the record being deleted exists" do

          let(:giraffe) { model.create }

          before do
            model.create
            giraffe
            model.create
          end

          it "should delete the record with the matching id" do
            database.delete giraffe.id

            model.count.must_equal 2
            model.where(id: giraffe.id).count.must_equal 0
          end

          it "should return true" do
            database.delete(giraffe.id).must_equal true
          end

        end

        describe "the record being deleted does not exist" do

          let(:giraffe) { model.create }

          before do
            model.create
            giraffe
            model.create
            giraffe.delete
          end

          it "should return falses" do
            database.delete(giraffe.id).must_equal false
          end

        end

      end

    end

  end

end
