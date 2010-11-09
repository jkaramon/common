require 'spec_helper'
require 'test_logger'

describe Jobs::QueueProcessor do
  
  class TestQueueJob < Jobs::QueueProcessor
    
    def queue_name
      "__test"
    end

    def process_message(data)
      info "Processing data '#{data}'"
    end
  end

  before(:each) do
    @logger = TestLogger.new
  end
  
  it "should execute empty queue job" do
    TestQueueJob.execute(:logger => @logger)
    @logger.infos.should include("Starting Testqueuejob job")
    @logger.infos.should include("Testqueuejob finished successfuly")
    @logger.errors.should be_empty
  end


  it "should process message" do
    job = TestQueueJob.new(:logger => @logger)
    queue = Messaging::Queue.new job.queue_name 
    queue.enqueue "hello !!!"
    job.execute    
    @logger.infos.should include("Starting Testqueuejob job")
    @logger.infos.should include("Testqueuejob finished successfuly")
    @logger.errors.should be_empty
  end



end
