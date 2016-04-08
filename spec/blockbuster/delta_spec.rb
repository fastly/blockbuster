require 'spec_helper'

describe Blockbuster::Delta do
  let(:configuration)    { Blockbuster::Configuration.new }
  let(:klass)            { Blockbuster::Delta }
  let(:instance)         { klass.new('some_file', configuration) }
  let(:current_instance) { klass.new(configuration.current_delta_name, configuration) }

  before do
    configuration.enable_deltas = true
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
          klass.new('some_file', configuration)
        end

        e.message.must_include 'Deltas are not enabled'
      end
    end

    describe 'deltas enabled' do
      it 'initializes with a configuration' do
        delta = klass.new('some_file', configuration)

        delta.configuration.must_equal configuration
      end

      it 'initializes with a file_name' do
        delta = klass.new('some_file', configuration)

        delta.file_name.must_equal 'some_file'
      end

      it 'initializes with current -> false if file_name != current_delta_name' do
        file_name = 'some_file'
        file_name.wont_equal configuration.current_delta_name

        delta = klass.new(file_name, configuration)
        delta.current.must_equal false
      end

      it 'initializes with current -> true if file_name == current_delta_name' do
        delta = klass.new(configuration.current_delta_name, configuration)
        delta.current.must_equal true
      end

      it 'ignores timestamps when deciding on setting `current`' do
        file_name = "#{Time.now.to_i}_some_file"
        delta = klass.new(file_name, configuration)
        delta.current.must_equal false

        delta = klass.new("#{Time.now.to_i}_#{configuration.current_delta_name}", configuration)
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
      expected = "#{configuration.full_delta_directory}/#{instance.file_name}"

      instance.file_path.must_equal expected
    end
  end

  describe '#target_path' do
    it 'returns a concatenation of full_delta_directory and current_time + _ + current_delta_name' do
      current_time = Time.now
      Time.stubs(:now).returns(current_time)

      expected = "#{configuration.full_delta_directory}/#{current_time.to_i}_#{configuration.current_delta_name}"

      instance.target_path.must_equal expected
    end
  end
end
