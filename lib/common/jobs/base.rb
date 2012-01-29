require 'logger'


module Jobs
  # Base job processor class. 
  # Class implements method execute which is typically called by periodic scheduler (cron)
  # Inherited classes should define job implementation in method perform  
  class Base
    include Logging
    include ErrorNotifier
    attr_accessor :tracker
    
    def initialize(options = {})
      @logger = options[:logger] 
      @tracker = options[:tracker] 
    end

    def self.execute(options = {})
      self.new(options).execute
    end

    def perform      
      raise "Implement by inheritor"
    end


    def tracker
      @tracker ||= Tracking::BaseTracker.new(self.class.to_s.demodulize.underscore)
    end


    def execute
      @tracker = Tracking::BaseTracker.new(self.class.to_s.demodulize.underscore)
      MongoMapper::Plugins::IdentityMap.clear
      perform
      self.tracker.set_success!
    rescue => err
      log_error(err)
    ensure 
      MongoMapper::Plugins::IdentityMap.clear
      self
    end
    
    def log_error(exc)
      error_note = "Error while processing #{job_name.humanize} job."
      error_message = "#{error_note} #{format_exception(exc)}"
      error error_message
      self.tracker.set_error!(error_message)
      notify_error(exc, :note => error_note, :current_site => MongoMapper.database.try(:name))
    end

    
    def info(message)
      super(message)
      tracker.info(message) if tracker
    end

    def error(message)
      super(message)
      tracker.error(message) if tracker
    end

    def warn(message)
      super(message)
      tracker.warn(message) if tracker
    end
    
    
 
    def job_name
      self.class.to_s
    end

  end
end
