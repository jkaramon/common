module Jobs
  module Tracking
    # MongoDB Queue processor tracker
    class QueueProcessorTracker < BaseTracker


      def initialize(name, message, data = {})
        super(name, data)
        @doc['message'] = message
        
      end
      

      
    end
  end
end
