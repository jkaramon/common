require 'spec_helper'
require 'state_machine'



describe "MongoMapper::Plugins::IdGenerator" do
  class Model 
    include MongoMapper::Document
    plugin MongoMapper::Plugins::IdGenerator
    id_format "MODEL-%05d" 
    
    key :name, String, :required => true

  end


  before(:each) do
    MongoMapper.database = 'rspec-common-test'
    Model.collection.remove
    Model.reset_counter
  end

  it "should return correct is after save" do
    @model = Model.create!(:name => 'My Model')
    @model.human_id_formatted.should == "MODEL-00001"
    @model.reload
    @model.human_id_formatted.should == "MODEL-00001"
  end
  
  it "should return correct subsequent ids" do
    Model.create!(:name => 'My Model')
    @model = Model.create!(:name => 'My Model')
    @model.human_id_formatted.should == "MODEL-00002"
  end
 
  it "should return correct subsequent ids if model creation failed" do
    Model.create.should be_new # invalid model
    @model = Model.create!(:name => 'My Model')
    @model.human_id_formatted.should == "MODEL-00001"
  end
 
  it "should return model by parsing its id" do
    Model.create.should be_new # invalid model
    @model = Model.create!(:name => 'My Model')
    @model.human_id_formatted.should == "MODEL-00001"
  end


end
