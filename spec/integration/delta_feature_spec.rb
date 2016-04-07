require 'spec_helper'

describe 'DeltaFeature' do
  let(:base_dir)    { 'spec/integration_fixtures' }
  let(:unique_id)   { Digest::MD5.hexdigest(location) }
  let(:unique_dir)  { "#{base_dir}/#{unique_id}" }
  let(:config)      { Blockbuster::Configuration.new }
  let(:manager)     { Blockbuster::Manager.new(config) }

  before do
    FileUtils.mkdir_p(unique_dir)
    FileUtils.copy("#{base_dir}/vcr_cassettes.tar.gz", "#{unique_dir}/vcr_cassettes.tar.gz", preserve: true)
    config.test_directory = unique_dir
    config.silent = true
  end

  after do
    FileUtils.rm_r(unique_dir)
  end

  describe 'feature disabled' do
    it 'does not initialize deltas' do
      Blockbuster::Delta.expects(:initialize_for_each).never
      manager.rent
      manager.drop_off
    end

    it 'does not change master if no files have changed' do
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      manager.drop_off

      new_master_mtime = File.mtime(config.master_tar_file_path)

      current_master_mtime.must_equal new_master_mtime
    end

    it 'it changes master if files have been deleted' do
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      FileUtils.rm("#{config.cassette_dir}/test_a.yml")
      manager.drop_off
      new_master_mtime = File.mtime(config.master_tar_file_path)

      current_master_mtime.wont_equal new_master_mtime
      manager.rent
      File.exist?("#{config.cassette_dir}/test_a.yml").must_equal false
    end

    it 'it changes master if files have been edited' do
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      File.truncate("#{config.cassette_dir}/test_a.yml", 0)
      manager.drop_off
      new_master_mtime = File.mtime(config.master_tar_file_path)

      current_master_mtime.wont_equal new_master_mtime
      File.exist?("#{config.cassette_dir}/test_a.yml").must_equal true
    end

    it 'creates master if master does not exist' do
      manager.rent
      FileUtils.rm(config.master_tar_file_path)
      File.exist?(config.master_tar_file_path).must_equal false

      manager_2 = Blockbuster::Manager.new(config)
      manager_2.rent
      manager_2.drop_off

      File.exist?(config.master_tar_file_path).must_equal true
    end
  end

  describe 'feature enabled' do
    before do
      config.enable_deltas = true
      FileUtils.cp_r("#{base_dir}/deltas/", unique_dir)
    end

    it 'does not change master if no files have changed' do
      current_master_mtime = File.mtime(config.master_tar_file_path)
      manager.rent
      manager.drop_off

      new_master_mtime = File.mtime(config.master_tar_file_path)
      current_master_mtime.must_equal new_master_mtime
    end

    it 'does not change master if files have been deleted' do
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      FileUtils.rm("#{config.cassette_dir}/test_a.yml")
      manager.drop_off
      new_master_mtime = File.mtime(config.master_tar_file_path)

      current_master_mtime.must_equal new_master_mtime
      manager_2 = Blockbuster::Manager.new(config)
      manager_2.rent
      File.exist?("#{config.cassette_dir}/test_a.yml").must_equal true
    end

    it 'does not change master if files have been edited' do
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      File.truncate("#{config.cassette_dir}/test_a.yml", 0)
      manager.drop_off
      new_master_mtime = File.mtime(config.master_tar_file_path)

      current_master_mtime.must_equal new_master_mtime
      File.exist?("#{config.cassette_dir}/test_a.yml").must_equal true
    end

    it 'creates master if master does not exist' do
      manager.rent
      FileUtils.rm(config.master_tar_file_path)
      File.exist?(config.master_tar_file_path).must_equal false

      manager_2 = Blockbuster::Manager.new(config)
      manager_2.rent
      manager_2.drop_off

      File.exist?(config.master_tar_file_path).must_equal true
    end

    it 'untars deltas and does not change if nothing has happened' do
    end

    it 'initializes deltas' do
      Blockbuster::Delta.expects(:initialize_for_each).once.returns([])
      manager.rent
      manager.drop_off
    end

    describe 'master -> delta 1 -> delta 2' do
      before do
        FileUtils.rm(config.master_tar_file_path)
        FileUtils.rm_rf(config.full_delta_directory)
        FileUtils.mkdir_p(config.cassette_dir)
        FileUtils.cp("#{base_dir}/cassettes/match_requests_on.yml", config.cassette_dir)
      end

      it 'first creates master, then creates delta 1, then creates delta 2' do
        # make sure we are starting from scratch
        File.exist?(config.master_tar_file_path).must_equal false
        Dir.exist?(config.full_delta_directory).must_equal false

        # we expect master to record, and a delta directory will be created
        manager_2 = Blockbuster::Manager.new(config)
        manager_2.rent
        manager_2.drop_off

        File.exist?(config.master_tar_file_path).must_equal true
        Dir.exist?(config.full_delta_directory).must_equal true
        Dir.glob("#{config.full_delta_directory}/*").must_equal []

        # let's verify our comparator extracts properly
        manager_3 = Blockbuster::Manager.new(config)
        manager_3.rent
        manager_3.comparator.keys.size.must_equal 1
        manager_3.comparator.hash['cassettes/match_requests_on.yml']['source'].must_equal config.master_tar_file
        manager_3.drop_off
        Dir.glob("#{config.full_delta_directory}/*").must_equal []

        # now let's get a delta going
        FileUtils.cp("#{base_dir}/cassettes/fake_example_response.yml", config.cassette_dir)

        manager_4 = Blockbuster::Manager.new(config)
        manager_4.rent
        manager_4.drop_off
        deltas = Dir.glob("#{config.full_delta_directory}/*")
        deltas.size.must_equal 1
        first_delta = deltas.first
        first_delta.must_match(%r{^#{config.full_delta_directory}\/\d+_#{config.current_delta_name}$})

        # and verify our comparator for proper extraction
        manager_5 = Blockbuster::Manager.new(config)
        manager_5.rent
        manager_5.comparator.keys.size.must_equal 2
        manager_5.comparator.hash['cassettes/match_requests_on.yml']['source'].must_equal config.master_tar_file
        manager_5.comparator.hash['cassettes/fake_example_response.yml']['source'].must_equal File.basename(first_delta)
        manager_5.drop_off

        # let's change the current delta name and make sure we can run without losing our delta
        config.current_delta_name = 'next_delta.tar.gz'
        manager_6 = Blockbuster::Manager.new(config)
        manager_6.rent
        manager_6.drop_off
        deltas = Dir.glob("#{config.full_delta_directory}/*")
        deltas.size.must_equal 1
        old_delta = deltas.first
        old_delta.must_match(%r{^#{first_delta}$})

        # ok, and now we add a file, and get a new delta
        FileUtils.cp("#{base_dir}/cassettes/some_crazy_test.yml", config.cassette_dir)
        manager_7 = Blockbuster::Manager.new(config)
        manager_7.rent
        manager_7.drop_off
        deltas = Dir.glob("#{config.full_delta_directory}/*").sort
        deltas.size.must_equal 2
        deltas.first.must_equal first_delta
        new_delta = deltas.last
        new_delta.must_match(%r{^#{config.full_delta_directory}\/\d+_#{config.current_delta_name}$})

        # and last verification that our comparator has proper extraction
        manager_8 = Blockbuster::Manager.new(config)
        manager_8.rent
        manager_8.comparator.keys.size.must_equal 3
        manager_8.comparator.hash['cassettes/match_requests_on.yml']['source'].must_equal config.master_tar_file
        manager_8.comparator.hash['cassettes/fake_example_response.yml']['source'].must_equal File.basename(first_delta)
        manager_8.comparator.hash['cassettes/some_crazy_test.yml']['source'].must_equal File.basename(new_delta)
        manager_8.drop_off
      end
    end

    describe 'regenerating master' do
    end
  end
end
