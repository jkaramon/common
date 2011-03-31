require 'spec_helper'

describe Messaging::Queue do
  
  before(:each) do
    @queue = Messaging::Queue.new 'rspec-test'
    @queue.delete
  end
  
  
  it "should process string message" do
    @queue.enqueue "MyString"
    data = @queue.dequeue
    data.should == "MyString" 
    @queue.dequeue.should be_nil
  end
  
  it "should process hash message" do
    @queue.enqueue({:my_key => "my_value"})
    data = @queue.dequeue
    data['my_key'].should == "my_value" 
    @queue.dequeue.should be_nil
  end

  describe "Routing" do
    
   
    describe "Routre to stable version" do
      before(:each) do
        @queue = Messaging::Queue.new 'rspec-test', :route_to => :stable
      end

      it "should route to stable messaging db in preprod" do
        @queue.test_env = "preprod"
        @queue.database.name.should == "messaging"
      end
      
      it "should route to stable messaging db in production" do
        @queue.test_env = "production"
        @queue.database.name.should == "messaging"
      end

      it "should route to ci messaging db in ci" do
        @queue.test_env = "ci"
        @queue.database.name.should == "messaging-ci"
      end
    
    end

    describe "Routre to beta version" do
      before(:each) do
        @queue = Messaging::Queue.new 'rspec-test', :route_to => :beta
      end

      it "should route to beta messaging db in preprod" do
        @queue.test_env = "preprod"
        @queue.database.name.should == "messaging-preprod"
      end
      
      it "should route to beta messaging db in production" do
        @queue.test_env = "production"
        @queue.database.name.should == "messaging-preprod"
      end

      it "should route to ci messaging db in ci" do
        @queue.test_env = "ci"
        @queue.database.name.should == "messaging-ci"
      end
    
    end


  end

 
end
