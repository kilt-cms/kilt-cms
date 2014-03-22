require File.expand_path(File.dirname(__FILE__) + '/../../minitest_helper')
require 'rails/generators'
require_relative '../../../lib/generators/kilt/backend_generator'

describe Kilt::Generators::BackendGenerator do

  it "should exist" do
    #raise Kilt::Generators::BackendGenerator.new.destination_root.inspect
    #raise Kilt::Generators::BackendGenerator.new.public_methods(true).inspect
    #raise Kilt::Generators::BackendGenerator.new.public_methods(true).inspect
  end

  describe "generate" do

    let(:generator) { Kilt::Generators::BackendGenerator.new }

    let(:root) do
      Object.new
    end

    let(:parent_name) { 'test' }

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

    it "should be able to be called without erroring" do
      generator.generate
    end

  end

end
