require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Form do

  describe "method_missing" do

    ['blah', 'another', 'apple'].each do |method|

      describe "when the view exists" do

        it "should return the content of the view" do

          object     = Object.new
          field_name = Object.new
          index      = Object.new
          options    = Object.new
          view       = Object.new

          html = Object.new

          view.stubs(:render).with( { partial: "kilt/form/#{method}", 
                                      locals:  {
                                                 object:     object,
                                                 field_name: field_name,
                                                 index:      index,
                                                 options:    options,
                                                 view:       view
                                               } } ).returns html

          result = Kilt::Form.send(method.to_sym, object, field_name, index, view, options)
          
          result.must_be_same_as html

        end

      end

      describe "when the view does not exist" do

        it "should return the content of the default view" do

          object     = Object.new
          field_name = Object.new
          index      = Object.new
          options    = Object.new
          view       = Object.new

          html = Object.new

          view.stubs(:render).with( { partial: "kilt/form/#{method}", 
                                      locals:  {
                                                 object:     object,
                                                 field_name: field_name,
                                                 index:      index,
                                                 options:    options,
                                                 view:       view
                                               } } ).raises 'error'

          view.stubs(:render).with( { partial: "kilt/form/default", 
                                      locals:  {
                                                 object:     object,
                                                 field_name: field_name,
                                                 index:      index,
                                                 options:    options,
                                                 view:       view
                                               } } ).returns html

          result = Kilt::Form.send(method.to_sym, object, field_name, index, view, options)
          
          result.must_be_same_as html

        end

      end

    end

  end

end
