require 'spec_helper'

module Blockbuster
  describe Configuration do
    let(:klass)         { Configuration }
    let(:configuration) { klass.new }

    it 'is an instance of Blockbuster::Configuration' do
      configuration.must_be_instance_of klass
    end

    it 'has configuration attributes' do
      attrs = [
        :cassette_directory,
        :cassette_file,
        :local_mode,
        :test_directory,
        :wipe_cassette_dir,
        :silent
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

    describe '#cassette_file' do
      it 'defaults to CASSETTE_FILE' do
        configuration.cassette_file.must_equal klass::CASSETTE_FILE
      end

      it 'returns assigned value' do
        configuration.cassette_file = 'somefile'

        configuration.cassette_file.must_equal 'somefile'
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
  end
end
