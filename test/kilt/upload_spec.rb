require File.expand_path(File.dirname(__FILE__) + '/../minitest_helper')

describe Kilt::Upload do

  let(:config)  { Struct.new(:storage).new storage }
  let(:storage) { Struct.new(:strategy).new strategy }

  before do
    Kilt.stubs(:config).returns config
  end

  describe "do" do

    let(:type) { Object.new  }

    let(:file_reference) do
      Struct.new(:original_filename, :read).new Object.new, nil
    end

    describe "using the local strategy" do

      let(:strategy) { 'local' }

      it "should ensure that the local storage dir exists" do
        Kilt::Utils.expects(:ensure_local_storage_dir_exists)
        Kilt::Upload.do type, file_reference
      end

    end

  end

end
