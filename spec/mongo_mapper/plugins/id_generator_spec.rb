require 'spec_helper'
require 'state_machine'



describe "MongoMapper::Plugins::IdGenerator" do
  class Model 
    include MongoMapper::Document
    plugin MongoMapper::Plugins::IdGenerator
    id_format "MODEL-%05d" 
    id_parse_format /MODEL-(?<human_id>\d{5})/
    
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

  describe "Find" do
  
    before(:each) do
      @model1 = Model.create!(:name => 'Model 1')
      @model2 = Model.create!(:name => 'Model 1') 
    end
    
    it "should find first model by human id" do
      Model.find('MODEL-00001').should == @model1
    end

    it "should find second model by human id" do
      Model.find('MODEL-00002').should == @model2
    end
    
    it "should find first model by id" do
      Model.find(@model1.id).should == @model1
    end

    it "should find second model by id" do
      Model.find(@model2.id).should == @model2
    end

    it "should not find model given no id" do
      Model.find(nil).should be_nil
    end

     it "should not find model given empty id" do
      Model.find('').should be_nil
    end

    it "should not find model given empty id" do
      Model.find('00002').should be_nil
    end

  end


end
