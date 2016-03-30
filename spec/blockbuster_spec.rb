require 'spec_helper'

describe Blockbuster do
  it 'has a version number' do
    Blockbuster::VERSION.wont_be_nil
  end

  let(:cassette_directory) { 'somedir' }
  let(:cassette_file)      { 'somefile' }
  let(:a_test_directory)   { 'sometestdir' }
  let(:silent)             { true }
  let(:local_mode)         { false }
  let(:wipe_cassette_dir)  { false }
  let(:configuration)      { Blockbuster.configuration }
  let(:configure) do
    Blockbuster.configure do |c|
      c.cassette_directory = cassette_directory
      c.cassette_file      = cassette_file
      c.test_directory     = a_test_directory
      c.silent             = silent
      c.local_mode         = local_mode
      c.wipe_cassette_dir  = wipe_cassette_dir
    end
  end

  let(:unconfigure) do
    Blockbuster.instance_variable_set(:@configuration, Blockbuster::Configuration.new)
  end

  describe 'not configured' do
    before do
      unconfigure
    end

    describe '.configuration' do
      it 'returns a Blockbuster::Configuration instance' do
        configuration.must_be_instance_of Blockbuster::Configuration
      end

      it 'has default attributes' do
        configuration.silent.must_equal Blockbuster::Configuration::SILENT
      end
    end
  end

  describe 'configured' do
    before do
      configure
    end

    it 'returns actual values for configuration attributes' do
      configuration.cassette_directory.must_equal cassette_directory
      configuration.cassette_file.must_equal cassette_file
      configuration.test_directory.must_equal a_test_directory
      configuration.silent.must_equal silent
      configuration.local_mode.must_equal local_mode
      configuration.wipe_cassette_dir.must_equal wipe_cassette_dir
    end
  end

  after do
    unconfigure
  end
end
