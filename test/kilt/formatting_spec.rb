require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Formatting do

  describe "singular type of" do

    [
      [:horse,               'Horse'],
      [:cat,                 'Cat'],
      [:no_namey,            'No Namey'],
      [:big_green_alligator, 'Big Green Alligator'],
    ].map { |x| Struct.new(:type, :expected).new(*x) }.each do |example|

      describe "multiple examples" do

        it "should return the singular form of the kilt object" do
          object = Kilt::Object.new example.type
          Kilt::Formatting.singular_name_of(object).must_equal example.expected
        end

        it "should retur the singular form of the symbol" do
          Kilt::Formatting.singular_name_of(example.type).must_equal example.expected
        end

      end

    end

  end

end
