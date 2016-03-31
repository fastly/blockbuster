require 'spec_helper'

describe Blockbuster::Comparison do
  let(:klass)    { Blockbuster::Comparison }
  let(:instance) { klass.new }

  describe '#add' do
    it 'adds the given key and value to the comparison object' do
      instance.keys.wont_include 'a'
      instance.add('a', 'b')
      instance.keys.must_include 'a'
    end
  end

  describe '#delete' do
    it 'deletes the given key' do
      instance.add('a', 'b')
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
      instance.add('a', 'b')
      instance.add('b', 'c')
      instance.keys.size.must_be :>, 0
      instance.keys.sort.must_equal %w(a b)
    end
  end

  describe '#present?' do
    it 'returns false when there are no keys' do
      instance.keys.must_be_empty
      instance.present?.must_equal false
    end

    it 'returns true when there are keys' do
      instance.add('a', 'b')
      instance.keys.wont_be_empty
      instance.present?.must_equal true
    end
  end
end
