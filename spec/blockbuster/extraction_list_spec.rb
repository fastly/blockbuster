require 'spec_helper'

describe Blockbuster::ExtractionList do
  let(:configuration)     { Blockbuster::Configuration.new }
  let(:klass)             { Blockbuster::ExtractionList }
  let(:comparator)        { Blockbuster::Comparator.new(configuration) }
  let(:instance)          { klass.new(comparator, configuration) }

  describe '#files' do
    it 'returns an array with the first element as a Blockbuster::Master' do
      instance.files.must_be_instance_of Array
      instance.files.first.must_be_instance_of Blockbuster::Master
    end
  end

  describe '#master' do
    it 'returns an instance of Blockbuster::Master' do
      instance.master.must_be_instance_of Blockbuster::Master
    end
  end

  describe '#primary' do
    it 'returns master when deltas are disabled' do
      configuration.deltas_disabled?.must_equal true
      instance.primary.must_be_instance_of Blockbuster::Master
    end
  end

  describe '#extract_cassettes' do
    it 'runs `extract_cassettes` on each item returned in `files`' do
      instance.files.each do |file|
        file.expects(:extract_cassettes).once
      end

      instance.extract_cassettes
    end
  end

  describe 'deltas enabled' do
    let(:delta_one) { Blockbuster::Delta.new('delta_one', comparator, configuration) }
    let(:delta_two) { Blockbuster::Delta.new('delta_two', comparator, configuration) }

    before do
      configuration.stubs(:deltas_enabled?).returns(true)
    end

    describe '#files' do
      it 'still returns an array with the first element as a Blockbuster::Master' do
        instance.files.must_be_instance_of Array
        instance.files.first.must_be_instance_of Blockbuster::Master
      end

      it 'includes all deltas returned by `Delta.initialize_for_each`' do
        Blockbuster::Delta.stubs(:initialize_for_each).returns([delta_one, delta_two])

        instance.files.size.must_be :>, 1
        instance.files.first.must_be_instance_of Blockbuster::Master

        (1..instance.files.size - 1).each do |i|
          instance.files[i].must_be_instance_of Blockbuster::Delta
        end
      end

      describe '#deltas' do
        it 'returns a collection of Blockbuster::Delta objects' do
          instance.deltas.must_be_instance_of Array
          instance.deltas.size.must_be :>, 0
          instance.deltas.each do |delta|
            delta.must_be_instance_of Blockbuster::Delta
          end
        end
      end

      describe '#current_delta' do
        it 'returns the Blockbuster::Delta marked as `current`' do
          delta = instance.current_delta

          delta.current?.must_equal true
        end
      end

      describe '#primary' do
        before do
          FileUtils.mkdir_p(configuration.test_directory)
          FileUtils.touch(configuration.master_tar_file_path)
        end

        it 'returns master if no master file exists' do
          File.stubs(:exist?).with(Blockbuster::Master.new(comparator, configuration).file_path).returns(false)

          instance.primary.must_be_instance_of Blockbuster::Master
        end

        it 'returns the current delta' do
          File.exist?(Blockbuster::Master.new(comparator, configuration).file_path).must_equal true

          primary = instance.primary
          primary.must_be_instance_of Blockbuster::Delta
          primary.current?.must_equal true
        end
      end

      describe '#extract_cassettes' do
        it 'runs `extract_cassettes` on each item returned in `files`' do
          instance.files.each do |file|
            file.expects(:extract_cassettes).once
          end

          instance.extract_cassettes
        end
      end
    end
  end
end
