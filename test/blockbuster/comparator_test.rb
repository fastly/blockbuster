require 'test_helper'

describe Blockbuster::Comparator do
  let(:configuration)   { Blockbuster::Configuration.new }
  let(:klass)           { Blockbuster::Comparator }
  let(:instance)        { klass.new(configuration) }

  before do
    configuration.silent = true
  end

  describe '#add' do
    it 'adds the given key and value to the comparison object' do
      instance.keys.wont_include 'a'
      instance.add('a', 'b', 'c')
      instance.keys.must_include 'a'

      instance.inventory['a'].must_equal 'content' => 'b', 'source' => 'c'
    end
  end

  describe '#delete' do
    it 'deletes the given key' do
      instance.add('a', 'b', 'c')
      instance.keys.must_include 'a'
      instance.delete('a')
      instance.keys.wont_include 'a'
    end

    it 'does not raise if key provided is not present' do
      instance.keys.wont_include 'a'
      instance.delete('a')
    end
  end

  describe '#keys' do
    it 'returns an empty array when there are no keys' do
      instance.keys.size.must_equal 0
      instance.keys.must_equal []
    end

    it 'returns an array of the comparison keys' do
      instance.add('a', 'b', 'c')
      instance.add('b', 'c', 'd')
      instance.keys.size.must_be :>, 0
      instance.keys.sort.must_equal %w[a b]
    end
  end

  describe '#present?' do
    it 'returns false when there are no keys' do
      instance.keys.must_be_empty
      instance.present?.must_equal false
    end

    it 'returns true when there are keys' do
      instance.add('a', 'b', 'c')
      instance.keys.wont_be_empty
      instance.present?.must_equal true
    end
  end

  describe '#compare' do
    it 'returns true if first argument does not exist as hash key' do
      instance.keys.include?('fakekey').must_equal false

      instance.compare('fakekey', 'blah').must_equal true
    end

    it 'returns true if hash-key "content" value != second argument' do
      instance.add('somekey', 'somevalue', 'somesource')

      instance.compare('somekey', 'newvalue').must_equal true
    end

    it 'returns nil otherwise' do
      instance.add('somekey', 'somevalue', 'somesource')

      instance.compare('somekey', 'somevalue').must_equal nil
    end
  end

  describe '#edited?' do
    it 'returns false if given argument does not exist in internal edited array' do
      instance.instance_variable_get(:@edited).must_equal []

      instance.edited?('somename').must_equal false
    end

    it 'returns true if given argument exists in internal edited array' do
      instance.instance_variable_set(:@edited, ['i_exist'])

      instance.edited?('i_exist').must_equal true
    end
  end

  describe '#store_current_delta_files' do
    it 'does not add files to current_delta_files list if `source` != `current_delta_name`' do
      source_name = 'blah'
      source_name.wont_equal configuration.current_delta_name

      instance.add('a', 'b', source_name)

      instance.store_current_delta_files

      instance.current_delta_files.wont_include 'a'
    end

    it 'adds files to current_delta_files list if `source` == `current_delta_name' do
      instance.add('a', 'b', configuration.current_delta_name)

      instance.store_current_delta_files

      instance.current_delta_files.must_include 'a'
    end
  end

  describe '#rewind?' do
    it 'returns true if there are keys present and deltas are disabled' do
      instance.add('a', 'b', 'c')
      instance.present?.must_equal true
      configuration.deltas_disabled?.must_equal true

      instance.rewind?([]).must_equal true
    end

    it 'returns false if there are no edited files' do
      instance.present?.must_equal false

      instance.edited.must_be :empty?

      instance.rewind?([]).must_equal false
    end

    it 'returns true if there are edited files' do
      instance.present?.must_equal false

      instance.instance_variable_set(:@edited, ['a'])

      instance.rewind?([]).must_equal true
    end
  end

  describe '#any_deleted?' do
    describe 'deltas disabled' do
      before do
        configuration.deltas_disabled?.must_equal true
      end

      it 'returns true if there are any items in the `deleted` queue' do
        instance.instance_variable_set(:@deleted, %w[a])

        instance.any_deleted?.must_equal true
      end

      it 'returns false' do
        instance.deleted.must_equal []

        instance.any_deleted?.must_equal false
      end
    end

    describe 'deltas_disabled' do
      before do
        configuration.enable_deltas = true
      end

      it 'returns true if intersection of `current_delta_files` and `deleted` is not empty' do
        instance.instance_variable_set(:@current_delta_files, %w[a b])
        instance.instance_variable_set(:@deleted, %w[b])

        (instance.current_delta_files & instance.deleted).wont_be :empty?

        instance.any_deleted?.must_equal true
      end

      it 'returns false' do
        (instance.current_delta_files & instance.deleted).must_be :empty?

        instance.any_deleted?.must_equal false
      end
    end
  end
end
