require 'spec_helper'
require 'state_machine'

class TestModel
  include MongoMapper::Document
  plugin MongoMapper::Plugins::StateTerminated
  
  state_machine :initial => :draft do
    event :do_activate do
      transition [:inactive] => :active
    end

    event :do_deactivate do
      transition [:active] => :inactive
    end

    event :do_save do
      transition [:active, :inactive] => same
    end

    event :do_create do
      transition [:draft] => :active
    end
  end
end

describe "MongoMapper::Plugins::StateTerminated" do
  before(:each) do
    MongoMapper.database = 'rspec-common-test'
    TestModel.collection.remove
    @entity = TestModel.new
  end

  it "should be in terminated state after terminated" do
    @entity.do_terminate
    @entity.state.should == "terminated"
  end
end