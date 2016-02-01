require 'spec_helper'

describe Blockbuster do

  it 'has a version number' do
    Blockbuster::VERSION.wont_be_nil
  end

  describe 'Blockbuster::Manager' do
    let(:klass) { Blockbuster::Manager }

    describe 'constructor' do
      let(:cass_dir)  { '/foo/bar' }
      let(:cass_file) { 'betamax.tar.gz' }
      let(:tst_dir)   { 'zspec' }

      it 'has default attributes' do
        manager = klass.new

        manager.cassette_directory.must_equal klass::CASSETTE_DIRECTORY
        manager.cassette_file.must_equal klass::CASSETTE_FILE
        manager.test_directory.must_equal klass::TEST_DIRECTORY
      end

      it 'can be intialized with attributes' do
        mgr = klass.new(cassette_directory: cass_dir)
        mgr.cassette_directory.must_equal cass_dir

        mgr = klass.new(cassette_file: cass_file)
        mgr.cassette_file.must_equal cass_file

        mgr = klass.new(test_directory: tst_dir)
        mgr.test_directory.must_equal tst_dir
      end
    end
  end
end
