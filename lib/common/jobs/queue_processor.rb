require 'logger'


module Jobs
  # Base class for processing queue messages as commands
  # Inherited classes should define job implementation in method process_message
  # and queue_name method to return actual queue name
  class QueueProcessor < Base

    # Implemented by inheritors. Should return actual queue name
    def queue_name
      raise "Not Implemented. Implement in inheritor"
    end

    def execute(options = {})
      queue = Messaging::Queue.new queue_name
      processed_messages = 0
      while message = queue.dequeue_message
        processed_messages += 1
        @tracker = Tracking::QueueProcessorTracker.new(self.class.to_s.demodulize.underscore, message)
        begin
          MongoMapper::Plugins::IdentityMap.clear
          info "Processing message #{message.to_s}"
          process_message(message[:data])
          info  "Processing finished successfuly"
          self.tracker.set_success!
        rescue => err
          log_error(err)
        ensure
          MongoMapper::Plugins::IdentityMap.clear
        end
      end
      if processed_messages > 0
        @tracker = Tracking::QueueProcessorTracker.new(self.class.to_s.demodulize.underscore, message)
        info "#{processed_messages}  processed mesages from queue #{queue_name}"
        info  "#{job_name.humanize} finished successfuly"
        self.tracker.set_success!
      end
      self
    end

  end
end
