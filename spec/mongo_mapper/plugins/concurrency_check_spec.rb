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

  it "should check concurrency update" do
    first = ConcurrencyCheckModel.find(@entity.id)
    second = ConcurrencyCheckModel.find(@entity.id)
    first.name = "1 subject"
    second.name = "2 subject"
    first.save!
    expect{second.save}.to raise_error("Document has been modified")
  end
end
