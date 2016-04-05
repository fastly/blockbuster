require 'spec_helper'

describe Blockbuster::Delta do
  let(:klass)              { Blockbuster::Delta }
  let(:current_delta_name) { Blockbuster.configuration.current_delta_name }
  let(:dir)                { klass.full_delta_directory }
  let(:current_time)       { Time.now.to_i }

  describe '.files' do
    it 'returns an empty array when there are no tests' do
      FileUtils.rm Dir.glob("#{klass.full_delta_directory}/*.tar.gz")
      klass.files.must_equal []
    end

    it 'returns an list of files ordered by time' do
      dir = klass.full_delta_directory
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")

      FileUtils.touch("#{dir}/#{current_time - 30}_c.tar.gz")
      FileUtils.touch("#{dir}/#{current_time - 20}_b.tar.gz")
      FileUtils.touch("#{dir}/#{current_time - 10}_a.tar.gz")

      klass.files.must_equal ["#{dir}/#{current_time - 30}_c.tar.gz",
                              "#{dir}/#{current_time - 20}_b.tar.gz",
                              "#{dir}/#{current_time - 10}_a.tar.gz"]
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
      deltas[0].file_path.must_equal "#{dir}/#{current_delta_name}"
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
      File.directory?(dir).must_equal true
      File.exist?("#{dir}/.keep").must_equal true
    end
  end

  let(:delta) { klass.new("#{dir}/#{current_time}_#{current_delta_name}") }

  describe '#initialize' do
    it 'raises NotEnabledError if deltas are not enabled' do
      Blockbuster.configuration.stubs(:deltas_disabled?).returns(true)

      proc { klass.new('') }.must_raise klass::NotEnabledError
    end

    it 'sets @current to true if it is the current delta using a fuzzy match' do
      Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

      delta.current?.must_equal true
    end

    it 'the filename does not include the path' do
      Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

      delta.file_name.must_equal "#{current_time}_#{current_delta_name}"
    end
  end

  describe '#file_path' do
    it 'is the delta director + filename' do
    Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

    delta.file_path.must_equal "#{dir}/#{current_time}_#{current_delta_name}"
    end
  end

  describe '#target_path' do
    it 'is the director + the delta name prefixed with the current time in epoch format' do
    Blockbuster.configuration.stubs(:deltas_disabled?).returns(false)

    current_time
    Time.expects(:now).returns(current_time)
    delta.target_path.must_equal "#{dir}/#{current_time}_#{current_delta_name}"
    end
  end
end
