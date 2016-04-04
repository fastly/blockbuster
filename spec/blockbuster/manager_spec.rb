require 'spec_helper'

describe Blockbuster::Manager do
  let(:klass) { Blockbuster::Manager }

  describe 'constructor' do
    let(:cass_dir)  { '/foo/bar' }
    let(:cass_file) { 'betamax.tar.gz' }
    let(:tst_dir)   { 'zspec' }

    it 'has default attributes' do
      manager = klass.new

      manager.cassette_directory.must_equal Blockbuster.configuration.cassette_directory
      manager.master_tar_file.must_equal Blockbuster.configuration.master_tar_file
      manager.local_mode.must_equal false
      manager.test_directory.must_equal Blockbuster.configuration.test_directory
      manager.silent.must_equal false
      manager.wipe_cassette_dir.must_equal Blockbuster.configuration.wipe_cassette_dir
    end
  end

  describe 'instance methods' do
    let(:my_test_dir)       { File.join(File.dirname(__FILE__), '..', 'fixtures') }
    let(:cassette_dir)      { 'cassettes' }
    let(:cassette_dir_path) { File.join(my_test_dir, 'cassettes') }
    let(:cassette_1)        { File.join(cassette_dir_path, 'match_requests_on.yml') }
    let(:cassette_2)        { File.join(cassette_dir_path, 'fake_example_response.yml') }
    let(:manager)           { klass.new }

    before do
      Blockbuster.configure do |c|
        c.test_directory = my_test_dir
        c.master_tar_file = 'test_cassettes.tar.gz'
        c.cassette_directory = cassette_dir
        c.silent = true
      end

      Blockbuster.instance_variable_set(:@comparator, Blockbuster::Comparator.new)
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
        Blockbuster.configuration.stub(:master_tar_file, 'nosuchfile.tar.gz') do
          manager = klass.new

          manager.rent.must_equal false
        end
      end

      it 'extracts cassette files' do
        manager.master_tar_file.must_equal 'test_cassettes.tar.gz'
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

        Blockbuster.comparator.keys.must_include 'cassettes/match_requests_on.yml'
        Blockbuster.comparator.keys.must_include 'cassettes/fake_example_response.yml'
      end

      describe 'wipe_cassette_dir option' do
        before do
          manager.master_tar_file.must_equal 'test_cassettes.tar.gz'
          manager.rent
          FileUtils.touch(File.join(cassette_dir_path, 'fakefile'))
        end

        it 'wipes the existing cassette directory if wipe_cassette_dir is true' do
          Blockbuster.configuration.stub(:wipe_cassette_dir, true) do
            manager.wipe_cassette_dir.must_equal true

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
      let(:cass)      { manager.send(:master_tar_file_path) }
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
        Blockbuster.configuration.stub(:silent?, false) do
          proc { manager.drop_off(force: true) }.must_output(/Recreating cassette file/)
        end

        File.mtime(cass).must_be :!=, File.mtime(orig_cass)
      end

      it 'creates a new cassette file if rewind? is true' do
        open(cassette_2, 'a') do |file|
          file << 'new recording'
        end
        Blockbuster.configuration.stub(:silent?, false) do
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
        Blockbuster.comparator.rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal false
      end

      it 'returns true if a cassette file was changed' do
        open(cassette_2, 'a') do |file|
          file << 'new recording'
        end
        Blockbuster.configuration.stub(:silent?, false) do
          proc { Blockbuster.comparator.rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/Cassette changed: /)
        end
      end

      it 'returns true if no comparison was created' do
        Blockbuster.stub(:comparator, Blockbuster::Comparator.new) do
          Blockbuster.configuration.stub(:silent?, false) do
            proc { Blockbuster.comparator.rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/New cassette: /)
          end
        end
      end

      it 'returns false if a file was deleted from the cassettes directory' do
        FileUtils.rm(cassette_1)
        Blockbuster.configuration.stub(:silent?, false) do
          proc { Blockbuster.comparator.rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/Cassettes deleted: /)
        end
      end

      it 'returns false if a file was added to the cassettes directory' do
        new_cass = File.join(cassette_dir_path, 'new_cass.yml')
        FileUtils.touch(new_cass)
        Blockbuster.configuration.stub(:silent?, false) do
          proc { Blockbuster.comparator.rewind?(Dir.glob("#{cassette_dir_path}/**/*")).must_equal true }.must_output(/New cassette: /)
        end
      end
    end
  end
end
