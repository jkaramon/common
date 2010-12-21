require 'spec_helper'

class HierachicalModel
  include MongoMapper::Document
  key :name, String
  plugin MongoMapper::Plugins::HierarchicalEntity
end



describe MongoMapper::Plugins::HierarchicalEntity do

  before(:all) do
   MongoMapper.database = 'rspec-common-test' 
  end
 
  describe "Defined keys" do
    before(:each) do
      @entity = HierachicalModel.new
    end

    it "should have defined parent_id" do
      @entity.should respond_to(:parent_id)     
    end

    it "should have defined parent" do
      @entity.should respond_to(:parent)
    end

  end 

  
  describe "Hierarchy
     root  _____
      |        |
      v        v
    l1_ch1   l1_ch2
      |
      v
    l2_ch1
      |
      v
    l3_ch1" do

    before(:all) do
      HierachicalModel.collection.remove
      @root = HierachicalModel.create!(:name => 'root' )
      @l1_ch1 = HierachicalModel.create!( :name => 'l1_ch1', :parent => @root )
      @l1_ch2 = HierachicalModel.create!( :name => 'l1_ch2', :parent => @root )
      @l2_ch1 = HierachicalModel.create!( :name => 'l2_ch1', :parent => @l1_ch1 )
      @l3_ch1 = HierachicalModel.create!( :name => 'l3_ch1', :parent => @l2_ch1 )
      @all = [ @root, @l1_ch1, @l1_ch2, @l2_ch1, @l3_ch1 ]
    end

    it "root should have no parent" do
      @root.parent.should be_nil    
    end
    
    it "should have correct name" do
      @root.name.should == "root" 
    end
    
    it "should have correct parent name" do
      @l1_ch1.parent_name.should == "root" 
    end
   
     it "should have correct ascendant_and_self_ids array" do
      @l3_ch1.ascendant_and_self_ids.should == [@root.id, @l1_ch1.id, @l2_ch1.id, @l3_ch1.id ]
    end

    it "should have correct ascendant_ids array" do
      @l3_ch1.ascendant_ids.should == [@root.id, @l1_ch1.id, @l2_ch1.id ]
    end


    it "should have correct id_path" do
      @l3_ch1.id_path.should == "#{@root.id}:#{@l1_ch1.id}:#{@l2_ch1.id}:#{@l3_ch1.id}"
    end

    it "should have correct full_name" do
      @l2_ch1.full_name.should == "#{@root.name} / #{@l1_ch1.name} / #{@l2_ch1.name}"
    end

    it "should have correct descendants" do
      @root.descendants.should include( @l1_ch1, @l1_ch2, @l2_ch1, @l3_ch1 )
    end

    it "should have correct descendant count" do
      @root.descendants.should have( 4 ).items
    end
    

    describe "Possible Parents" do
      
      subject { HierachicalModel.possible_parents(@l2_ch1) }
      
      it "should reject self" do
        subject.should_not include(@l2_ch1)
      end
      
      it "should reject already assigned child" do
        subject.should_not include(@l3_ch1)
      end

      it "should accept entity on another branch" do
        subject.should include(@l1_ch2)
      end


    end

    describe "Process Descendants" do
      it "process_self_and_descendants should change all names" do
        
        @root.process_self_and_descendants do |entity|
          entity.name = "change 1"
        end
        @all.each { |entity| entity.name.should == "change 1" }
      end

      it "process_descendants_and_self should change all names" do
        
        @root.process_descendants_and_self do |entity|
          entity.name = "change 2"
        end
        @all.each { |entity| entity.name.should == "change 2" }
      end

    end


   
  end 



end
