require 'spec_helper'

describe 'DeltaFeature' do
  let(:base_dir)    { 'spec/integration_fixtures/' }
  let(:unique_id)   { Digest::MD5.hexdigest(location) }
  let(:unique_dir)  { "#{base_dir}#{unique_id}" }
  let(:config)      { Blockbuster::Configuration.new }
  let(:manager)     { Blockbuster::Manager.new(config) }

  before do
    FileUtils.mkdir_p(unique_dir)
    FileUtils.copy("#{base_dir}vcr_cassettes.tar.gz", "#{unique_dir}/vcr_cassettes.tar.gz", preserve: true)
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
      current_master_mtime = File.mtime(config.master_tar_file_path)

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
      current_master_mtime = File.mtime(config.master_tar_file_path)

      manager.rent
      FileUtils.rm(config.master_tar_file_path)
      File.exist?(config.master_tar_file_path).must_equal false

      manager_2 = Blockbuster::Manager.new(config)
      manager_2.rent
      manager_2.drop_off


      File.exist?(config.master_tar_file_path).must_equal true
    end

    describe 'delta directory setup' do
      it 'generates deltas directory if none exists' do
      end
    end

    it 'initializes deltas' do
      Blockbuster::Delta.expects(:initialize_for_each).once.returns([])
      manager.rent
      manager.drop_off
    end

    describe 'no master exists' do
    end

    describe 'regenerating master' do
    end
  end
end
