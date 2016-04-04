require 'spec_helper'

describe Blockbuster::Delta do
  let(:klass) { Blockbuster::Delta }
  let(:dir)   { klass.full_delta_directory }

  describe '.files' do

    it 'returns an empty array when there are no tests' do
      FileUtils.rm Dir.glob("#{klass.full_delta_directory}/*.tar.gz")
      klass.files.must_equal []
    end

    it 'returns an list of files ordered by time' do
      dir = klass.full_delta_directory
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")
      time = Time.now.to_i
      FileUtils.touch("#{dir}/#{time - 30}_c.tar.gz")
      FileUtils.touch("#{dir}/#{time - 20}_b.tar.gz")
      FileUtils.touch("#{dir}/#{time - 10}_a.tar.gz")

      klass.files.must_equal ["#{dir}/#{time - 30}_c.tar.gz", "#{dir}/#{time - 20}_b.tar.gz", "#{dir}/#{time - 10}_a.tar.gz"]      
    end
  end

  describe '.initialize_for_each' do

    it 'calls .setup_directory and .files once' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")    
      klass.expects(:setup_directory)
      klass.expects(:files).returns([])
      Blockbuster.configuration.expects(:deltas_disabled?).returns(false)

      klass.initialize_for_each
    end

    it 'returns an array of Delta objects' do
      Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

      klass.initialize_for_each.must_be_instance_of Array
      klass.initialize_for_each[0].must_be_instance_of klass
    end

    it 'if there are no deltas the array includes the current delta' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")    
      Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

      deltas = klass.initialize_for_each
      deltas.size.must_equal 1
      deltas[0].current?.must_equal true
      deltas[0].file_path.must_equal "#{dir}/#{Blockbuster.configuration.current_delta_name}"
    end
  end

  describe '.setup_directory' do

    it 'returns early if the directory exists' do
      klass.setup_directory
      FileUtils.expects(:mkdir_p).never

      klass.setup_directory
    end

    it 'creates the directory and adds a .keep file if it does not exist' do
      FileUtils.rm_r dir

      klass.setup_directory
      File.directory?(dir)
      File.exist?("#{dir}/.keep").must_equal true
    end
  end
end
