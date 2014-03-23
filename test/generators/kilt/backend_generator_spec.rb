require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')
require 'rails/generators'
require_relative '../../../lib/generators/kilt/backend_generator'

describe Kilt::Generators::BackendGenerator do

  describe "generate" do

    let(:generator) { Kilt::Generators::BackendGenerator.new }

    let(:root) do
      Object.new
    end

    let(:parent_name) { 'Test' }

    before do
      generator.stubs(:template)
      generator.stubs(:copy_file)
      generator.stubs(:inject_into_file)

      Rails.stubs(:root).returns root

      root.stubs(:join)

      application = Object.new
      klass       = Object.new
      Rails.stubs(:application).returns application
      application.stubs(:class).returns klass
      klass.stubs(:parent_name).returns parent_name
    end

    it "should copy the default config file to the app" do
      root_result = Object.new
      root.stubs(:join).with('config', 'kilt', 'config.yml').returns root_result
      generator.expects(:template).with 'config.yml.erb', root_result
      generator.generate
    end

    it "should copy the default credential file to the app" do
      root_result = Object.new
      root.stubs(:join).with('config', 'kilt', 'creds.yml.example').returns root_result
      generator.expects(:copy_file).with 'creds.yml.example', root_result
      generator.generate
    end

    it "should copy the kilt.rb file as an app initializer" do
      root_result = Object.new
      root.stubs(:join).with('config', 'initializers', 'kilt.rb').returns root_result
      generator.expects(:copy_file).with 'kilt.rb', root_result
      generator.generate
    end

    it "should inject the Kilt routes into a Rails 4.0 app's routes" do
      root_result = Object.new
      root.stubs(:join).with('config', 'routes.rb').returns root_result
      generator.expects(:inject_into_file).with root_result, "\n\tmount Kilt::Engine => '/admin', as: 'kilt_engine'\n", :after => "Test::Application.routes.draw do\n"
      generator.generate
    end

    it "should inject the Kilt routes into a Rails 4.1 app's routes" do
      root_result = Object.new
      root.stubs(:join).with('config', 'routes.rb').returns root_result
      generator.expects(:inject_into_file).with root_result, "\n\tmount Kilt::Engine => '/admin', as: 'kilt_engine'\n", :after => "Rails.application.routes.draw do\n"
      generator.generate
    end

  end

end
