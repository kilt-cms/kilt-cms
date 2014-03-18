require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Object do

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

  describe "assembling the fields" do

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

      end

    end

  end

end
