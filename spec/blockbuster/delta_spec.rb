require 'spec_helper'

describe Blockbuster::Delta do
  let(:configuration)      { Blockbuster::Configuration.new }
  let(:comparator)         { Blockbuster::Comparator.new(configuration) }
  let(:klass)              { Blockbuster::Delta }
  let(:dir)                { configuration.full_delta_directory }
  let(:current_time)       { Time.now.to_i }
  let(:current_delta_name) { configuration.current_delta_name }
  let(:instance)           { klass.new('some_file', comparator, configuration) }
  let(:current_instance)   { klass.new(current_delta_name, comparator, configuration) }

  before do
    configuration.enable_deltas = true
  end

  describe '.files' do
    it 'returns an empty array when there are no tests' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")
      klass.files(dir).must_equal []
    end

    it 'returns an list of files ordered by time' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")

      FileUtils.touch("#{dir}/#{current_time - 30}_c.tar.gz")
      FileUtils.touch("#{dir}/#{current_time - 20}_b.tar.gz")
      FileUtils.touch("#{dir}/#{current_time - 10}_a.tar.gz")

      klass.files(dir).must_equal ["#{current_time - 30}_c.tar.gz", "#{current_time - 20}_b.tar.gz", "#{current_time - 10}_a.tar.gz"]
    end
  end

  describe '.initialize_for_each' do
    it 'calls .setup_directory and .files once' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")
      klass.expects(:setup_directory).with(dir)
      klass.expects(:files).with(dir).returns([])
      configuration.expects(:deltas_disabled?).returns(false)

      klass.initialize_for_each(comparator, configuration)
    end

    it 'returns an array of Delta objects' do
      configuration.stubs(:deltas_disabled?).returns(false)

      response = klass.initialize_for_each(comparator, configuration)
      response.must_be_instance_of Array
      response[0].must_be_instance_of klass
    end

    it 'if there are no deltas the array includes the current delta' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")
      configuration.stubs(:deltas_disabled?).returns(false)

      deltas = klass.initialize_for_each(comparator, configuration)
      deltas.size.must_equal 1
      deltas[0].current?.must_equal true
      deltas[0].file_path.must_equal "#{dir}/#{klass::INITIALIZING_NUMBER}_#{current_delta_name}"
    end

    it 'does not blow up when the delta name starts with digits and an underscore' do
      FileUtils.rm Dir.glob("#{dir}/*.tar.gz")
      configuration.stubs(:deltas_disabled?).returns(false)
      configuration.current_delta_name = '123_testing.tar.gz'

      deltas = klass.initialize_for_each(comparator, configuration)
      deltas.size.must_equal 1
      deltas[0].current?.must_equal true
      deltas[0].file_path.must_equal "#{dir}/#{klass::INITIALIZING_NUMBER}_#{current_delta_name}"
    end
  end

  describe '.setup_directory' do
    it 'returns early if the directory exists' do
      klass.setup_directory(dir)
      FileUtils.expects(:mkdir_p).never

      klass.setup_directory(dir)
    end

    it 'creates the directory and adds a .keep file if it does not exist' do
      FileUtils.rm_r dir

      klass.setup_directory(dir)
      File.directory?(dir).must_equal true
      File.exist?("#{dir}/.keep").must_equal true
    end
  end

  describe '.file_name_without_timestamp' do
    it 'scrubs all digits and first underscore of the given string' do
      expected = 'some_file.tar.gz'

      klass.file_name_without_timestamp("12345_#{expected}").must_equal expected
    end

    it 'is a no-op without digits' do
      expected = 'some_file.tar.gz'

      klass.file_name_without_timestamp(expected).must_equal expected
    end
  end

  describe '#initialize' do
    describe 'deltas disabled' do
      before do
        configuration.enable_deltas = false
      end

      it 'returns NotEnabledError' do
        e = assert_raises klass::NotEnabledError do
          klass.new('some_file', comparator, configuration)
        end

        e.message.must_include 'Deltas are not enabled'
      end
    end

    describe 'deltas enabled' do
      it 'initializes with a configuration' do
        delta = klass.new('some_file', comparator, configuration)

        delta.configuration.must_equal configuration
      end

      it 'initializes with a file_name' do
        delta = klass.new('some_file', comparator, configuration)

        delta.file_name.must_equal 'some_file'
      end

      it 'initializes with current -> false if file_name != current_delta_name' do
        file_name = 'some_file'
        file_name.wont_equal current_delta_name

        delta = klass.new(file_name, comparator, configuration)
        delta.current.must_equal false
      end

      it 'initializes with current -> true if file_name == current_delta_name' do
        delta = klass.new(current_delta_name, comparator, configuration)
        delta.current.must_equal true
      end

      it 'ignores timestamps when deciding on setting `current`' do
        file_name = "#{Time.now.to_i}_some_file"
        delta = klass.new(file_name, comparator, configuration)
        delta.current.must_equal false

        delta = klass.new("#{Time.now.to_i}_#{current_delta_name}", comparator, configuration)
        delta.current.must_equal true
      end
    end
  end

  describe '#file_name_without_timestamp' do
    it 'delegates to class method' do
      klass.expects(:file_name_without_timestamp).with(instance.file_name).at_least_once

      instance.file_name_without_timestamp
    end
  end

  describe '#current' do
    it 'returns false when file_name != current_delta_name' do
      instance.current.must_equal false
    end

    it 'returns true when file_name == current_delta_name' do
      current_instance.current.must_equal true
    end
  end

  describe '#current?' do
    it 'is an alias for current' do
      instance.current?.must_equal instance.current
      current_instance.current?.must_equal current_instance.current
    end
  end

  describe '#file_path' do
    it 'returns a concatenation of full_delta_directory and file_name' do
      expected = "#{dir}/#{instance.file_name}"

      instance.file_path.must_equal expected
    end
  end

  describe '#target_path' do
    it 'returns a concatenation of full_delta_directory and current_time + _ + current_delta_name' do
      current_time = Time.now
      Time.stubs(:now).returns(current_time)

      expected = "#{dir}/#{current_time.to_i}_#{current_delta_name}"

      instance.target_path.must_equal expected
    end
  end
end
