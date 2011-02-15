require 'spec_helper'
require 'state_machine'

class StateTerminateModel
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
    StateTerminateModel.collection.remove
    @entity = StateTerminateModel.new
  end

  it "should be in terminated state after terminated" do
    @entity.do_terminate
    @entity.state.should == "terminated"
  end

  it "method all should return 2 results from 3, one is terminated" do
    terminated_entity = StateTerminateModel.new
    terminated_entity.do_terminate
    first_entity = StateTerminateModel.new
    first_entity.do_create
    second_entity = StateTerminateModel.new
    second_entity.do_create
    
    StateTerminateModel.all.count.should == 2
  end

  it "paginate should return 1 result from 4 (two per page, one terminated, second page) " do
    terminated_entity = StateTerminateModel.new
    terminated_entity.do_terminate
    first_entity = StateTerminateModel.new
    first_entity.do_create
    second_entity = StateTerminateModel.new
    second_entity.do_create
    third_entity = StateTerminateModel.new
    third_entity.do_create
    options = {
      :per_page  => 2,
      :page      => 2
    }
    StateTerminateModel.paginate(options).count.should == 1
  end


end