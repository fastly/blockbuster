require 'spec_helper'

describe Blockbuster::Master do
  let(:configuration) { Blockbuster::Configuration.new }
  let(:comparator)    { Blockbuster::Comparator.new(configuration) }
  let(:klass)         { Blockbuster::Master }
  let(:instance)      { klass.new(comparator, configuration) }

  describe '#initialize' do
    it 'initializes with a configuration object' do
      instance.configuration.must_equal configuration
    end

    it 'initializes and sets the file name to master_tar_file' do
      instance.file_name.must_equal configuration.master_tar_file
    end
  end

  describe '#file_path' do
    it 'returns master_tar_file_path' do
      instance.file_path.must_equal configuration.master_tar_file_path
    end
  end

  describe '#target_path' do
    it 'is the same as file_path' do
      instance.target_path.must_equal instance.file_path
    end
  end
end
