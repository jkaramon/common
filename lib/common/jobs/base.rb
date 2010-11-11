require 'logger'


module Jobs
  # Base job processor class. 
  # Class implements method execute which is typically called by periodic scheduler (cron)
  # Inherited classes should define job implementation in method perform  
  class Base
    include Logging
    attr_accessor :tracker
    
    def initialize(options = {})
      @logger = options[:logger]  
    end

    def self.execute(options = {})
      self.new(options).execute
    end

    def perform      
      raise "Implement by inheritor"
    end


    def execute
      @tracker = Tracking::BaseTracker.new(self.class.to_s.demodulize.underscore)
      tracker.track!
      info "Starting #{job_name.humanize} job"
      perform
      info  "#{job_name.humanize} job finished successfuly"
      tracker.set_success!
    rescue => err
      error_message = "Error while processing #{job_name.humanize} job #{format_exception(err)}"
      error error_message
      tracker.set_error!(error_message)
    end

    
    def info(message)
      super(message)
      tracker.info(message) if tracker
    end

    def error(message)
      super(message)
      tracker.error(message) if tracker
    end

 
    def job_name
      self.class.to_s
    end

  end
end