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
      Struct.new(:original_filename, :read, :tempfile).new SecureRandom.uuid, nil, Object.new
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

      let(:type) { SecureRandom.uuid  }

      let(:s3_config) do
        Struct.new(:key, :secret, :bucket)
              .new(Object.new, Object.new, Object.new)
      end

      let(:s3)       {  Object.new }
      let(:bucket)   { Object.new }
      let(:buckets)  { Object.new }
      let(:objects)  { Object.new }
      let(:the_file) { Object.new }

      let(:the_location_of_the_temp_file) { Object.new }

      before do
        Kilt::Utils.stubs(:ensure_s3_bucket_exists)
        config.stubs(:s3).returns s3_config

        AWS::S3.stubs(:new)
               .with(access_key_id:     s3_config.key,
                     secret_access_key: s3_config.secret)
               .returns s3

        s3.stubs(:buckets).returns buckets
        buckets.stubs(:[]).with(s3_config.bucket).returns bucket

        bucket.stubs(:objects).returns objects

        objects.stubs(:[])
               .with("#{type}/#{file_reference.original_filename}")
               .returns the_file

        Pathname.stubs(:new)
                .with(file_reference.tempfile)
                .returns the_location_of_the_temp_file

        the_file.stubs(:write)
      end

      it "should ensure that the s3 bucket exists" do
        Kilt::Utils.expects(:ensure_s3_bucket_exists)
        Kilt::Upload.do type, file_reference
      end

      it "should write the file to the bucket" do
        the_file.expects(:write).with(the_location_of_the_temp_file, { acl: :public_read } )
        Kilt::Upload.do type, file_reference
      end

      it "should return the original filename" do
        result = Kilt::Upload.do type, file_reference
        result.must_be_same_as file_reference.original_filename
      end

      describe "when the s3 write fails" do

        before do
          the_file.expects(:write).raises 'error'
        end

        it "should eat the error" do
          # this better not fail
          Kilt::Upload.do type, file_reference
        end

        it "should return an empty string" do
          result = Kilt::Upload.do type, file_reference
          result.must_equal ''
        end

      end

      describe "when there is an error getting the s3 object" do
        before do
          AWS::S3.stubs(:new).raises 'error'
        end

        it "should eat the error" do
          # this better not fail
          Kilt::Upload.do type, file_reference
        end

        it "should return an empty string" do
          result = Kilt::Upload.do type, file_reference
          result.must_equal ''
        end
      end

    end

    describe "when no file reference is passed with a s3 type" do

      let(:strategy) { 's3' }

      before do
        Kilt::Utils.stubs(:ensure_s3_bucket_exists)
      end

      it "should ensure that the s3 bucket exists" do
        Kilt::Utils.expects(:ensure_s3_bucket_exists)
        Kilt::Upload.do type, nil
      end

      it "should not attempt to hit s3" do
        AWS::S3.expects(:new).never
        Kilt::Upload.do type, nil
      end

      it "should return an empty string" do
        result = Kilt::Upload.do type, nil
        result.must_equal ''
      end

    end

  end

  describe "field types" do

    let(:strategy)       { Object.new }
    let(:file_reference) { Object.new }

    [:image, :file].each do |type|

      describe type do

        it "should call the do method and return the result" do
          expected_result = Object.new

          Kilt::Upload.stubs(:do)
                      .with(type.to_s, file_reference)
                      .returns expected_result

          result = Kilt::Upload.send type, file_reference

          result.must_be_same_as expected_result
        end

      end

    end

  end

  describe "uploadable types" do

    let(:strategy) { nil }

    describe "and no config was set" do

      before do
        config.stubs(:uploadable_types).returns nil
      end

      it "should return file and image" do
        types = Kilt::Upload.uploadable_types
        types.count.must_equal 2
        types.include?('file').must_equal true
        types.include?('image').must_equal true
      end
    end

    describe "and the fields were overridden by config" do

      before do
        config.stubs(:uploadable_types).returns 'a, b, c'
      end

      it "should return file and image" do
        types = Kilt::Upload.uploadable_types
        types.include?('file').must_equal true
        types.include?('image').must_equal true
      end

      it "should return the types" do
        types = Kilt::Upload.uploadable_types
        types.include?('a').must_equal true
        types.include?('b').must_equal true
        types.include?('c').must_equal true
      end

    end

    describe "and some edge cases" do

      before do
        config.stubs(:uploadable_types).returns 'r, r, r, file, image, q, s'
      end

      it "should return every type only once" do
        types = Kilt::Upload.uploadable_types
        types.count.must_equal 5
        types.include?('r').must_equal true
        types.include?('q').must_equal true
        types.include?('s').must_equal true
        types.include?('file').must_equal true
        types.include?('image').must_equal true
      end

    end

  end

end
