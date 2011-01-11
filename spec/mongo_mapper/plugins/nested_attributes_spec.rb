require 'spec_helper'

class Team
  include MongoMapper::Document
  plugin MongoMapper::Plugins::NestedAttributes
  key :name, String
  many :players
end

class Player
  include MongoMapper::EmbeddedDocument
  key :name, String
end

describe "NestedAttributes" do
  
  before(:all) do
    Team.set_database_name 'mongo_mapper_spec'
    Team.collection.drop
  end
  
  before(:each) do
    Team.accepts_nested_attributes_for(:players, :allow_destroy => true)
    @team = Team.new
    @team.update_attributes(:name => 'Nested Attributes',
      :players_attributes => [{:name => 'Normal guy'}, {:name => 'Special guy'}])
  end
  
  describe "Passing nested attributes" do
    it "should assign players to the new Team" do
      @team = Team.new(:name => 'Nested Attributes', :players_attributes => [{:name => 'Normal guy'}, {:name => 'Special guy'}])
      @team.should have(2).players
    end
  end
  
end
