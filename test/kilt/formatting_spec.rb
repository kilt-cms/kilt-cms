require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Formatting do

  describe "getting the formatted names of things" do

    [
      [:horse,               'Horse',               'Horses'],
      [:cat,                 'Cat',                 'Cats'],
      [:no_namey,            'No Namey',            'No Nameys'],
      [:big_green_alligator, 'Big Green Alligator', 'Big Green Alligators'],
    ].map { |x| Struct.new(:type, :singular, :plural).new(*x) }.each do |example|

      describe "multiple examples" do

        it "should return the singular form of the kilt object" do
          object = Kilt::Object.new example.type
          Kilt::Formatting.singular_name_of(object).must_equal example.singular
        end

        it "should return the singular form of the symbol" do
          Kilt::Formatting.singular_name_of(example.type).must_equal example.singular
        end

        it "should return the singular form of the string" do
          Kilt::Formatting.singular_name_of(example.type.to_s).must_equal example.singular
        end

        it "should return the plural form of the kilt object" do
          object = Kilt::Object.new example.type
          Kilt::Formatting.plural_name_of(object).must_equal example.plural
        end

        it "should return the plural form of the symbol" do
          Kilt::Formatting.plural_name_of(example.type).must_equal example.plural
        end

        it "should return the plural form of the string" do
          Kilt::Formatting.plural_name_of(example.type.to_s).must_equal example.plural
        end

      end

    end

  end

end
