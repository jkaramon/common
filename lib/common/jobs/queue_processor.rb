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
      info "Starting #{job_name.humanize} job"
      info "Processing queue #{queue_name}"
      processed_messages = 0
      while message = queue.dequeue_message
        processed_messages += 1
        @tracker = Tracking::QueueProcessorTracker.new(self.class.to_s.demodulize.underscore, message)
        tracker.track!
        begin
          info "Processing message #{message.to_s}"
          process_message(message[:data])
          info  "Processing finished successfuly"
          tracker.set_success!
        rescue => err
          log_error(err)
        end
      end
      info "Total processed mesages: #{processed_messages}"
      info  "#{job_name.humanize} finished successfuly"
      self
    end

  end
end
