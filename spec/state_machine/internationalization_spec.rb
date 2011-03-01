require 'spec_helper'
require 'state_machine'

class StateMachineInternationalizationModel
  include MongoMapper::Document
  plugin StateMachine::Internationalization

  state_machine :initial => :draft do
    event :do_activate do
      transition [:inactive] => :active
    end
  end
end

describe "StateMachineInternationalization" do
  
  before(:each) do
    MongoMapper.database = 'rspec-common-test'
    StateMachineInternationalizationModel.collection.remove
  end

  it " should respond to state_display_name method if plugin used" do
    entity = StateMachineInternationalizationModel.new
    entity.respond_to?(:state_display_name).should be_true
  end

end