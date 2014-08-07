require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

class ElephantViewModel < KiltViewModel
end

class TigerViewModel < KiltViewModel
end

describe KiltViewModel do

  describe "basic features" do

    it "should serve as a wrapper over a hash" do

      hash = { 'first_name' => 'John', 'last_name' => 'Galt' }

      view_model = KiltViewModel.new hash

      view_model.first_name.must_equal 'John'
      view_model.last_name.must_equal 'Galt'

    end

    it "should work with symbols as well as strings" do

      hash = { city: 'Olathe', 'state' => 'KS' }

      view_model = KiltViewModel.new hash

      view_model.city.must_equal 'Olathe'
      view_model.state.must_equal 'KS'
        
    end

  end

  describe "building view models" do

    [
      ['elephant', ElephantViewModel], 
      ['tiger',    TigerViewModel]
    ].map { |x| Struct.new(:the_type, :the_class).new(*x) }.each do |example|

      describe "building single view models" do

        it "should use the type to build a view model with a matching name" do

          data = { 'type' => example.the_type }

          view_model = KiltViewModel.build data

          view_model.is_a?(example.the_class).must_equal true
            
        end

      end

    end

    describe "building arrays of view models" do

      it "should return an array with each item as the proper type, for arrays" do
          
        records = [ { 'type' => 'elephant' },
                    { 'type' => 'tiger'    } ]

        view_models = KiltViewModel.build records

        view_models.count.must_equal 2

        view_models[0].is_a?(ElephantViewModel).must_equal true
        view_models[1].is_a?(TigerViewModel).must_equal true

      end

      it "should return an array with each item as the proper type, for KiltCollection" do
          
        records = Kilt::ObjectCollection.new([ { 'type' => 'elephant'},
                                               { 'type' => 'tiger' } ])

        view_models = KiltViewModel.build records

        view_models.count.must_equal 2
        view_models[0].is_a?(ElephantViewModel).must_equal true
        view_models[1].is_a?(TigerViewModel).must_equal true

      end

      it "should sort items by a sequence field, if sequence exists" do
          
        records = [ { 'name' => 'A', 'sequence' => '3' },
                    { 'name' => 'B', 'sequence' => '2' },
                    { 'name' => 'C', 'sequence' => '1' },
                    { 'name' => 'D', 'sequence' => nil },
                    { 'name' => 'E', 'sequence' => 'A' }]

        view_models = KiltViewModel.build records

        view_models.count.must_equal 5

        view_models[0].name.must_equal 'C'
        view_models[1].name.must_equal 'B'
        view_models[2].name.must_equal 'A'
        view_models[3].name.must_equal 'D'
        view_models[4].name.must_equal 'E'

      end


    end

    describe "building a view model when none exists" do

      it "should return a KiltViewModel instead" do

        data = { 'type' => 'monkey' }

        view_model = KiltViewModel.build data

        view_model.is_a?(KiltViewModel).must_equal true
          
      end

    end

  end

end
