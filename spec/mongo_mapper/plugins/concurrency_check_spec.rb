require 'spec_helper'

class TestModel
  include MongoMapper::Document
  key :name, String
  plugin MongoMapper::Plugins::ConcurrencyCheck
end

describe "MongoMapper::Plugins::ConcurrencyCheck" do
  before(:all) do
    @entity = TestModel.new(:name => "Name1")
    @entity.save!
  end

  it "should check concurrency update" do
    first = TestModel.find(@entity.id)
    second = TestModel.find(@entity.id)
    first.name = "1 subject"
    second.name = "2 subject"
    first.save!
    expect{second.save}.to raise_error("Document has been modified")
  end
end