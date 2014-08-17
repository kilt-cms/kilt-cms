require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Upload do

  let(:config)  { Struct.new(:storage).new storage }
  let(:storage) { Struct.new(:strategy).new strategy }

  before do
    Kilt.stubs(:config).returns config
  end

  describe "do" do

    let(:type) { Object.new  }

    let(:root) { Object.new }

    let(:file_reference) do
      Struct.new(:original_filename, :read).new Object.new, nil
    end

    before do
      Rails.stubs(:root).returns root
      root.stubs(:join).returns nil
    end

    describe "using the local strategy" do

      let(:strategy) { 'local' }

      before do
        Kilt::Utils.stubs(:ensure_local_storage_dir_exists)
        File.stubs(:open)
        root.stubs(:join).returns Object.new
      end

      it "should ensure that the local storage dir exists" do
        File.stubs(:open)
        Kilt::Utils.expects(:ensure_local_storage_dir_exists)
        Kilt::Upload.do type, file_reference
      end

      it "should write the file to local storage" do
        location = Object.new
        root.stubs(:join)
            .with('public', 'uploads', type, file_reference.original_filename)
            .returns location

        File.expects(:open).with location, 'wb'

        Kilt::Upload.do type, file_reference
      end

      it "should return the original file reference" do
        result = Kilt::Upload.do type, file_reference
        result.must_be_same_as file_reference.original_filename
      end

      describe "given no file reference" do
        it "should no try to write a file" do
          File.stubs(:open).raises 'An error'
          Kilt::Upload.do type, nil
          # no error should be thrown
        end

        it "should return an empty string" do
          Kilt::Upload.do(type, nil).must_equal ''
        end
      end

    end

    describe "actually writing the file locally" do

      let(:strategy) { 'local' }

      let(:test_file) { "test/test_s3.txt" }

      before do
        File.delete(test_file) if File.exists? test_file
      end

      after do
        File.delete(test_file) if File.exists? test_file
      end

      it "should write the file" do
        Kilt::Utils.stubs(:ensure_local_storage_dir_exists)

        random_content = SecureRandom.uuid
        file_reference.stubs(:read).returns random_content
        root.stubs(:join).returns test_file

        Kilt::Upload.do type, file_reference

        File.open(test_file).read.must_equal random_content
      end

    end

    describe "uploading a file to s3" do

      let(:strategy) { 's3' }

      it "should ensure that the s3 bucket exists" do

        Kilt::Utils.expects(:ensure_s3_bucket_exists)

        Kilt::Upload.do type, file_reference

      end

    end

  end

end
