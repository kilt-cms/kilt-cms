require File.expand_path(File.dirname(__FILE__) + '/minitest_helper')

describe Kilt do

  describe "types" do

    [:keys,       :expected_results].to_objects {[
      [[1, 2, 3], ['1', '2', '3']],
      [[5, 6],    ['5', '6']]
    ]}.each do |scenario|

      describe "keys exist" do

        it "should return the keys from the objects in the Kilt config" do

          config  = Object.new
          objects = scenario.keys.reduce({}) { |t, i| t[i] = nil; t }

          config.stubs(:objects).returns objects
          Kilt.stubs(:config).returns config

          Kilt.types.must_equal scenario.expected_results

        end

      end

    end

  end

end
