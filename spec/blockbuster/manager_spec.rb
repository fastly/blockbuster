require 'spec_helper'

describe Blockbuster::Manager do
  let(:klass) { Blockbuster::Manager }

  describe 'constructor' do
    let(:cass_dir)  { '/foo/bar' }
    let(:cass_file) { 'betamax.tar.gz' }
    let(:tst_dir)   { 'zspec' }
    let(:configuration) { Blockbuster::Configuration.new }

    it 'has a default configuration' do
      manager = klass.new
      manager.configuration.must_be_instance_of Blockbuster::Configuration
    end
  end

  describe 'instance methods' do
    let(:my_test_dir)       { File.join(File.dirname(__FILE__), '..', 'fixtures') }
    let(:cassette_dir)      { 'cassettes' }
    let(:cassette_dir_path) { File.join(my_test_dir, 'cassettes') }
    let(:cassette_1)        { File.join(cassette_dir_path, 'match_requests_on.yml') }
    let(:cassette_2)        { File.join(cassette_dir_path, 'fake_example_response.yml') }
    let(:configuration)      { manager.configuration }
    let(:manager) do
      klass.new do |c|
        c.test_directory = my_test_dir
        c.master_tar_file = 'test_cassettes.tar.gz'
        c.cassette_directory = cassette_dir
        c.silent = true
      end
    end

    after do
      ENV['VCR_MODE'] = nil
      FileUtils.rm_r(cassette_dir_path) if Dir.exist?(cassette_dir_path)
      Blockbuster.instance_variable_set(:@configuration, nil)
    end

    describe '.rent' do
      it 'does nothing if ENV["VCR_MODE"] equals "local"' do
        ENV['VCR_MODE'] = 'local'
        manager.rent

        Dir.exist?(cassette_dir).must_equal false
      end

      it 'returns false if the master tar file does not exists' do
        configuration.master_tar_file = 'nosuchfile.tar.gz'

        manager.rent.must_equal false
      end

      it 'extracts cassette files' do
        configuration.master_tar_file.must_equal 'test_cassettes.tar.gz'
        manager.rent

        File.exist?(cassette_1).must_equal true
        File.exist?(cassette_2).must_equal true
        FileUtils.identical?(cassette_1, File.join(my_test_dir, 'match_requests_on.yml')).must_equal true
        FileUtils.identical?(cassette_2, File.join(my_test_dir, 'fake_example_response.yml')).must_equal true
      end

      it 'has an alias' do
        manager.must_respond_to :setup
      end

      it 'tracks a hash of each file for comparison upon teardown' do
        manager.rent

        manager.instance_variable_get(:@comparator).keys.must_include 'cassettes/match_requests_on.yml'
        manager.instance_variable_get(:@comparator).keys.must_include 'cassettes/fake_example_response.yml'
      end

      describe 'wipe_cassette_dir option' do
        before do
          manager.configuration.master_tar_file.must_equal 'test_cassettes.tar.gz'
          manager.rent
          FileUtils.touch(File.join(cassette_dir_path, 'fakefile'))
        end

        it 'wipes the existing cassette directory if wipe_cassette_dir is true' do
          configuration.stub(:wipe_cassette_dir, true) do
            manager.configuration.wipe_cassette_dir.must_equal true

            manager.rent

            File.exist?(File.join(cassette_dir_path, 'fakefile')).must_equal false
          end
        end

        it 'does not wipe the cassette directory if local_mode is true' do
          manager.instance_variable_set(:@wipe_cassette_dir, true)
          manager.instance_variable_set(:@local_mode, true)

          manager.rent

          File.exist?(File.join(cassette_dir_path, 'fakefile')).must_equal true
        end

        it 'leaves the cassete directory as is if wipe_cassette_dir is false' do
          manager.rent

          File.exist?(File.join(cassette_dir_path, 'fakefile')).must_equal true
        end
      end
    end

    describe '.drop_off' do
      let(:cass)      { manager.configuration.master_tar_file_path }
      let(:orig_cass) { "#{cass}.tmp" }

      before do
        manager.rent
        FileUtils.cp(cass, orig_cass, preserve: true)
      end

      after do
        FileUtils.mv(orig_cass, cass)
      end

      it 'does nothing if there were no changes' do
        manager.drop_off

        FileUtils.identical?(cass, orig_cass).must_equal true
        File.mtime(cass).must_be :==, File.mtime(orig_cass)
      end

      it 'creates a new cassette file if force is true' do
        configuration.stub(:silent?, false) do
          proc { manager.drop_off(force: true) }.must_output(/Recreating cassette file/)
        end

        File.mtime(cass).must_be :!=, File.mtime(orig_cass)
      end

      it 'creates a new cassette file if rewind? is true' do
        open(cassette_2, 'a') do |file|
          file << 'new recording'
        end
        configuration.stub(:silent?, false) do
          proc { manager.drop_off(force: true) }.must_output(/Recreating cassette file/)
        end

        FileUtils.identical?(cass, orig_cass).must_equal false
        File.mtime(cass).must_be :!=, File.mtime(orig_cass)
      end
    end

    describe '.rewind?' do
      before do
        manager.rent
      end

      it 'returns false if no files have changed' do
        manager.instance_variable_get(:@comparator).rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal false
      end

      it 'returns true if a cassette file was changed' do
        open(cassette_2, 'a') do |file|
          file << 'new recording'
        end
        configuration.stub(:silent?, false) do
          proc { manager.instance_variable_get(:@comparator).rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/Cassette changed: /)
        end
      end

      it 'returns true if no comparison was created' do
        manager.instance_variable_set(:@comparator, Blockbuster::Comparator.new(configuration))
        configuration.stub(:silent?, false) do
          proc { manager.instance_variable_get(:@comparator).rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/New cassette: /)
        end
      end

      it 'returns false if a file was deleted from the cassettes directory' do
        FileUtils.rm(cassette_1)
        configuration.stub(:silent?, false) do
          proc { manager.instance_variable_get(:@comparator).rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/Cassettes deleted: /)
        end
      end

      it 'returns false if a file was added to the cassettes directory' do
        new_cass = File.join(cassette_dir_path, 'new_cass.yml')
        FileUtils.touch(new_cass)
        configuration.stub(:silent?, false) do
          proc { manager.instance_variable_get(:@comparator).rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/New cassette: /)
        end
      end
    end
  end
end
