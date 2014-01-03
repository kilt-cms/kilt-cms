require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Form do

  describe "method_missing" do

    ['blah', 'another', 'apple'].each do |method|

      describe "when the view exists" do

        it "should return a rendered action view" do

          rendered_action_view = Object.new

          object     = Object.new
          field_name = Object.new
          index      = Object.new

          action_view = Object.new
          action_view.expects(:render)
                     .with(:file    => "#{method}.html.erb", 
                           :locals  => { 
                                         :object      => object, 
                                         :field_name  => field_name,
                                         :index       => index
                                       } )
                     .returns rendered_action_view

          ActionView::Base.stubs(:new)
                          .with(Kilt::Form::TEMPLATES_DIR)
                          .returns action_view

          result = Kilt::Form.send(method.to_sym, object, field_name, index)
          
          result.must_be_same_as rendered_action_view

        end

      end

      describe "when the view does not exist" do

        it "should return the default view" do

          rendered_action_view = Object.new

          object     = Object.new
          field_name = Object.new
          index      = Object.new

          action_view = Object.new
          action_view.expects(:render)
                     .with(:file    => "#{method}.html.erb", 
                           :locals  => { 
                                         :object      => object, 
                                         :field_name  => field_name,
                                         :index       => index
                                       } )
                     .raises 'error'

          action_view.expects(:render)
                     .with(:file    => "_default.html.erb", 
                           :locals  => { 
                                     :object     => object, 
                                     :field_name => field_name,
                                     :index       => index
                                   } )
                     .returns rendered_action_view

          ActionView::Base.stubs(:new)
                          .with(Kilt::Form::TEMPLATES_DIR)
                          .returns action_view

          result = Kilt::Form.send(method.to_sym, object, field_name, index)
          
          result.must_be_same_as rendered_action_view

        end

      end

    end

  end

end
