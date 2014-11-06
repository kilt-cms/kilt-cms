require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Slugger do

  describe "determining if a slug is unique" do

    let(:slug)     { Object.new }
    let(:database) { Object.new }
    let(:type)     { Object.new }
    let(:object)   { { 'type' => type } }

    before do
      Kilt::Utils.stubs(:database_for).with(type).returns database
    end

    describe "a record cannot be found for the slug" do

      before do
        database.stubs(:find).with(slug).returns nil
      end

      it "should return true" do
        Kilt::Slugger.slug_is_unique_for?(slug, object).must_equal true
      end

    end

    describe "a record can be found for the slug" do

      let(:record) { {} }

      before do
        database.stubs(:find).with(slug).returns record
      end

      describe "and the unique id on the object does not match the record" do

        before do
          record['unique_id'] = Object.new
          object['unique_id'] = Object.new
        end

        it "should return false" do
          Kilt::Slugger.slug_is_unique_for?(slug, object).must_equal false
        end

      end

      describe "and the unique id on the object matches the record" do

        before do
          record['unique_id'] = Object.new
          object['unique_id'] = record['unique_id']
        end

        it "should return true" do
          Kilt::Slugger.slug_is_unique_for?(slug, object).must_equal true
        end

      end
    end

  end

end
