require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Object do

  describe "defining an object" do
    describe "the object does not have a field type specified" do
      it "should have a name field" do
        name = Object.new

        object = Kilt::Object.new('no_namey')
        object.fill( { 'name' => name } )

        object['name'].must_be_same_as name
      end
    end
  end

  describe "[]" do

    let(:values) { {} }

    let(:object) do
      Kilt::Object.new('cat', values)
    end

    describe "html_safe is not defined" do
      it "should return values that were passed in" do
        value = Object.new
        values['fruit'] = value
        object['fruit'].must_equal value
      end
    end

    describe "html_safe is defined" do
      it "should return the html_safe value" do
        value, html_safe_value = Object.new, Object.new
        value.stubs(:html_safe).returns html_safe_value
        values['vegetable'] = value
        object['vegetable'].must_equal html_safe_value
      end
    end

    describe "looking up values by symbol" do
      it "should return the html_safe value" do
        value = Object.new
        values['mineral'] = value
        object[:mineral].must_equal value
      end
    end

    describe "the value does not exist" do
      it "should return nil" do
        values['animal'] = nil
        object['animal'].nil?.must_equal true
      end

      it "should return nil, even if nil is html_safe" do
        NilClass.any_instance.stubs(:html_safe).returns Object.new
        values['animal'] = nil
        object['animal'].nil?.must_equal true
      end
    end

  end

  describe "constructing an object" do

    ['cat', 'dog'].each do |type|

      describe "basic scenario" do

        let(:name) { Object.new }
        let(:size) { Object.new }

        let(:object) do
          Kilt::Object.new(type, { 'name' => name,
                                   'size' => size } )
        end

        it "should initialize the variables" do
          object['name'].must_be_same_as name
          object['size'].must_be_same_as size
        end

        it "should set the type" do
          object.type.must_equal type
        end

        it "should allow symbols to be used to retrieve values" do
          object[:name].must_be_same_as name
          object[:size].must_be_same_as size
        end

      end

      describe "using symbols as keys" do

        let(:name) { Object.new }
        let(:size) { Object.new }

        let(:object) do
          Kilt::Object.new(type, { :name => name,
                                   :size => size } )
        end

        it "should initialize the variables" do
          object['name'].must_be_same_as name
          object['size'].must_be_same_as size
        end

        it "should allow symbols to be used to retrieve values" do
          object[:name].must_be_same_as name
          object[:size].must_be_same_as size
        end

      end

    end

  end

  describe "fill" do

    describe "simple situation" do

      let(:object) { Kilt::Object.new('cat') }

      it "should set the values on the object" do
        name, size = 'the name', 'the size'
        object.fill( { 'name' => name, 'size' => size } )
        object['name'].must_equal name
        object['size'].must_equal size
      end

      it "should ignore fields that are not passed in the params" do
        name, size = 'the name', 'the value'
        object['name'] = name
        object.fill( { 'size' => size } )
        object['name'].must_equal name
        object['size'].must_equal size
      end

      it "should ignore values that are not tied to fields" do
        name = 'a name'
        object.fill( { 'name' => name, 'something_else' => 'testing value' } )
        object['name'].must_equal name
        object['something_else'].nil?.must_equal true
      end

      [
        ['cat', 'file',  'resume',   'a resume'],
        ['dog', 'image', 'headshot', 'a headshot']
      ].map { |x| Struct.new(:type, :field_type, :property, :value).new(*x) }.each do |scenario|

        describe "files and images" do

          let(:object) { Kilt::Object.new(scenario.type) }

          before do
            Kilt::Upload.stubs(:send)
          end

          it "should save the result of the file upload" do
            upload_result = Object.new
            Kilt::Upload.expects(:send).with(scenario.field_type, scenario.value).returns upload_result
            object.fill( { 'name' => 'x', scenario.property => scenario.value } )
            object[scenario.property].must_be_same_as upload_result
          end

          describe "the hidden value is set to clear" do
            it "should set the value to an empty string" do
              upload_result = Object.new
              object.fill( { 'name' => 'x', "#{scenario.property}-hidden" => 'clear' } )
              object[scenario.property].must_equal ''
            end
          end

          describe "the hidden value is set to clear AND the value is set" do
            it "should set the value to an empty string" do
              upload_result = Object.new
              Kilt::Upload.expects(:send).with(scenario.field_type, scenario.value).returns upload_result
              object.fill( { 'name' => 'x', scenario.property => scenario.value, "#{scenario.property}-hidden" => 'clear' } )
              object[scenario.property].must_be_same_as upload_result
            end
          end

        end

      end

    end

  end

end
