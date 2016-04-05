require 'spec_helper'

describe 'DeltaFeature' do
  # let(:manager) { Blockbuster::Manager.new }

  # describe 'feature disabled' do
  #   before do
  #     Blockbuster.instance_variable_set(:@configuration, Blockbuster::Configuration.new)
  #     Blockbuster.configuration.deltas_disabled?.must_equal true
  #     Blockbuster.configuration.stubs(:silent?).returns(true)
  #   end

  #   it 'does not initialize deltas' do
  #     Blockbuster::Delta.expects(:initialize_for_each).never
  #     manager.rent
  #     manager.drop_off
  #   end
  # end

  # describe 'feature enabled' do
  #   before do
  #     Blockbuster.instance_variable_set(:@configuration, Blockbuster::Configuration.new)
  #     Blockbuster.configuration.stubs(:deltas_enabled?).returns(true)
  #     Blockbuster.configuration.stubs(:silent?).returns(true)
  #   end

  #   describe 'delta directory setup' do
  #     it 'generates deltas directory if none exists' do
  #     end
  #   end

  #   it 'initializes deltas' do
  #     Blockbuster::Delta.expects(:initialize_for_each).once.returns([])

  #     manager.rent
  #     manager.drop_off
  #   end

  #   describe 'no master exists' do
  #   end

  #   describe 'regenerating master' do
  #   end
  # end
end
