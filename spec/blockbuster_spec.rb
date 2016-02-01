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
        manager.silent.must_equal false
      end

      it 'can be intialized with attributes' do
        mgr = klass.new(cassette_directory: cass_dir)
        mgr.cassette_directory.must_equal cass_dir

        mgr = klass.new(cassette_file: cass_file)
        mgr.cassette_file.must_equal cass_file

        mgr = klass.new(silent: true)
        mgr.silent.must_equal true

        mgr = klass.new(test_directory: tst_dir)
        mgr.test_directory.must_equal tst_dir
      end
    end

    describe '.rent' do
      let(:manager)      { klass.new }
      let(:my_test_dir)  { File.join(File.dirname(__FILE__), 'fixtures') }
      let(:cassette_dir) { File.join(my_test_dir, 'cassettes') }
      let(:cassette_1)   { File.join(cassette_dir, 'match_requests_on.yml') }
      let(:cassette_2)   { File.join(cassette_dir, 'fake_example_response.yml') }

      after do
        ENV['VCR_MODE'] = nil
        FileUtils.rm_r(cassette_dir) if Dir.exist?(cassette_dir)
      end

      it 'does nothing if ENV["VCR_MODE"] equals "local"' do
        ENV['VCR_MODE'] = 'local'
        manager.rent.must_equal false
      end

      it 'returns false if the cassette file does not exists' do
        manager = klass.new(cassette_file: 'nosuchfile.tar.gz', silent: true)

        manager.rent.must_equal false
      end

      it 'extracts cassette files' do
        manager = klass.new(test_directory: my_test_dir, cassette_file: 'test_cassettes.tar.gz', cassette_directory: cassette_dir, silent: true)

        manager.cassette_file.must_equal 'test_cassettes.tar.gz'
        manager.rent

        File.exist?(cassette_1).must_equal true
        File.exist?(cassette_2).must_equal true
        FileUtils.identical?(cassette_1, File.join(my_test_dir, 'match_requests_on.yml')).must_equal true
        FileUtils.identical?(cassette_2, File.join(my_test_dir, 'fake_example_response.yml')).must_equal true
      end

      it 'has an alias' do
        manager.must_respond_to :setup
      end
    end
  end
end
