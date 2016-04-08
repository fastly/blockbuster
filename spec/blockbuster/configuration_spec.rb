require 'spec_helper'

describe Blockbuster::Configuration do
  let(:klass)         { Blockbuster::Configuration }
  let(:configuration) { klass.new }

  it 'is an instance of Blockbuster::Configuration' do
    configuration.must_be_instance_of klass
  end

  it 'has configuration attributes' do
    attrs = [
      :cassette_directory,
      :master_tar_file,
      :local_mode,
      :test_directory,
      :wipe_cassette_dir,
      :silent,
      :enable_deltas,
      :delta_directory,
      :current_delta_name
    ]

    attrs.each do |attr|
      assert_respond_to configuration, attr
    end
  end

  describe '#cassette_directory' do
    it 'defaults to CASSETTE_DIRECTORY' do
      configuration.cassette_directory.must_equal klass::CASSETTE_DIRECTORY
    end

    it 'returns assigned value' do
      configuration.cassette_directory = 'somedir'

      configuration.cassette_directory.must_equal 'somedir'
    end
  end

  describe '#master_tar_file' do
    it 'defaults to MASTER_TAR_FILE' do
      configuration.master_tar_file.must_equal klass::MASTER_TAR_FILE
    end

    it 'returns assigned value' do
      configuration.master_tar_file = 'somefile'

      configuration.master_tar_file.must_equal 'somefile'
    end
  end

  describe '#test_directory' do
    it 'defaults to TEST_DIRECTORY' do
      configuration.test_directory.must_equal klass::TEST_DIRECTORY
    end

    it 'returns assigned value' do
      configuration.test_directory = 'somedir'

      configuration.test_directory.must_equal 'somedir'
    end
  end

  describe '#silent' do
    it 'defaults to SILENT' do
      configuration.silent.must_equal klass::SILENT
    end

    it 'returns assigned value' do
      configuration.silent = true

      configuration.silent.must_equal true
    end
  end

  describe '#silent?' do
    it 'is an alias for `silent`' do
      configuration.silent?.must_equal configuration.silent

      configuration.silent = true

      configuration.silent?.must_equal configuration.silent
    end
  end

  describe '#wipe_cassette_dir' do
    it 'defaults to WIPE_CASSETTE_DIR' do
      configuration.wipe_cassette_dir.must_equal klass::WIPE_CASSETTE_DIR
    end

    it 'returns assigned value' do
      configuration.wipe_cassette_dir = true

      configuration.wipe_cassette_dir.must_equal true
    end
  end

  describe '#local_mode' do
    it 'defaults to ENV[VCR_MODE] == LOCAL_MODE' do
      expected = ENV['VCR_MODE'] == klass::LOCAL_MODE

      configuration.local_mode.must_equal expected
    end

    it 'returns assigned value' do
      configuration.local_mode = true

      configuration.local_mode.must_equal true
    end
  end

  describe '#enable_deltas' do
    it 'defaults to ENABLE_DELTAS' do
      configuration.enable_deltas.must_equal klass::ENABLE_DELTAS
    end

    it 'returns assigned value' do
      configuration.enable_deltas = true

      configuration.enable_deltas.must_equal true
    end
  end

  describe '#deltas_enabled?' do
    it 'is an alias for `enable_deltas`' do
      configuration.deltas_enabled?.must_equal configuration.enable_deltas

      configuration.enable_deltas = true

      configuration.deltas_enabled?.must_equal configuration.enable_deltas
    end
  end

  describe '#deltas_disabled?' do
    it 'is true when `deltas_enabled?` is false' do
      configuration.deltas_enabled?.must_equal false
      configuration.deltas_disabled?.must_equal true
    end

    it 'is false when `deltas_enabled?` is true' do
      configuration.enable_deltas = true

      configuration.deltas_enabled?.must_equal true
      configuration.deltas_disabled?.must_equal false
    end
  end

  describe '#delta_directory' do
    it 'defaults to DELTA_DIRECTORY' do
      configuration.delta_directory.must_equal klass::DELTA_DIRECTORY
    end

    it 'returns assigned value' do
      configuration.delta_directory = 'somedir'

      configuration.delta_directory.must_equal 'somedir'
    end
  end

  describe '#current_delta_name' do
    it 'defaults to CURRENT_DELTA_NAME' do
      configuration.current_delta_name.must_equal klass::CURRENT_DELTA_NAME
    end

    it 'returns assigned value' do
      configuration.current_delta_name = 'somefile'

      configuration.current_delta_name.must_equal 'somefile'
    end
  end

  describe '#key_from_path' do
    it 'returns the cassette_dir/file given a full path to a file' do
      expected = "#{configuration.cassette_directory}/some_file.txt"
      file = "/Path/to/#{expected}"

      configuration.key_from_path(file).must_equal expected
    end
  end

  describe '#cassette_dir' do
    it 'returns a concatenation of test_directory and cassette_directory' do
      expected = "#{configuration.test_directory}/#{configuration.cassette_directory}"

      configuration.cassette_dir.must_equal expected
    end
  end

  describe '#master_tar_file_path' do
    it 'returns a concatenation of test_directory and the master_tar_file' do
      expected = "#{configuration.test_directory}/#{configuration.master_tar_file}"

      configuration.master_tar_file_path.must_equal expected
    end
  end
end
