require 'spec_helper'
require 'state_machine'

class StateHistoryUser
  include MongoMapper::Document
end



class StateHistoryModel
  include MongoMapper::Document
  plugin MongoMapper::Plugins::StateHistory

  state_machine :initial => :draft do

    after_transition any => any do |entity, transition|
      entity.update_state_history(transition)
    end


    event :do_save do
      transition [:draft, :open] => same
    end

    event :do_create do
      transition :draft => :open
    end

    event :do_close do
      transition :open => :closed
    end



  end


end

describe "MongoMapper::Plugins::StateHistory" do
  before(:each) do
    MongoMapper.database = 'rspec-common-test'
    StateHistoryModel.collection.remove
    StateHistoryUser.collection.remove
    @entity = StateHistoryModel.new
  end

  it "should track creation" do
    @entity.do_create!
    @entity.state_history_records.should have(1).record
    @entity.reload
    @entity.state_history_records.should have(1).record
  end

  it "should not track update without state change" do
    @entity.do_save!
    @entity.state_history_records.should have(0).record
  end

  it "should  track multiple state changes" do
    @entity.do_create!
    @entity.do_close!
    @entity.state_history_records.should have(2).record
  end

  it "should not track updated_by if does not respond to #current_user method" do
    @entity.do_create!
    @entity.state_history_records.first.updated_by.should be_nil
  end


  it "should  track updated_by if respond to #current_user method" do
    @entity.class_eval do
      attr_accessor :current_user
    end
    @entity.current_user = StateHistoryUser.new
    @entity.do_create!
    @entity.state_history_records.first.updated_by.should == @entity.current_user.id
  end


end
