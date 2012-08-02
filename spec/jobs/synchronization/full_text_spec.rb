require 'spec_helper'

describe Jobs::Synchronization::FullText do
  
  it "should text fulltext synchronization persistence" do
    storage = Jobs::Synchronization::FullText.new('test')
    storage.set_timestamp(123)
    storage.get_timestamp.should == 123
    storage.set_timestamp(124)
    storage.get_timestamp.should == 124
  end

end

