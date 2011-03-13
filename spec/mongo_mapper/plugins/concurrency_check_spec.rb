require 'spec_helper'

class ConcurrencyCheckModel
  include MongoMapper::Document
  key :name, String
  plugin MongoMapper::Plugins::ConcurrencyCheck

end

describe "MongoMapper::Plugins::ConcurrencyCheck" do
  before(:all) do
    MongoMapper.database = 'rspec-common-test' 
    @entity = ConcurrencyCheckModel.new(:name => "Name1")
    @entity.save!
  end

  it "unsaved entity should skip concurrency check" do
    unsaved = ConcurrencyCheckModel.new(:name => "Name1")
    unsaved.should be_valid
    unsaved.save.should be_true
  end

  it "unsaved entity should skip concurrency check even if update_attributes called" do
    unsaved = ConcurrencyCheckModel.new(:name => "Name1")
    unsaved.update_attributes(:name => 'Name2')
    unsaved.should be_valid
    unsaved.save.should be_true
  end


  it "should check concurrency update" do
    first = ConcurrencyCheckModel.find(@entity.id)
    second = ConcurrencyCheckModel.find(@entity.id)
    first.name = "1 subject"
    second.name = "2 subject"
    first.save!
    second.should_not be_valid
    second.errors.full_messages.first.should include("has been modified by someone else!") 
  end
end
