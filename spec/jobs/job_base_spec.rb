require 'spec_helper'
require 'test_logger'

describe Jobs::Base do
  
  class TestJob < Jobs::Base
    def perform
      "I am working ..."
    end
  end

  before(:each) do
    @logger = TestLogger.new
  end
  
  it "should execute TestJob" do
    TestJob.execute(:logger => @logger)
    @logger.infos.should be_empty
    @logger.errors.should be_empty
  end


end


