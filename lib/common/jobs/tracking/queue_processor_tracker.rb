module Jobs
  module Tracking
    # MongoDB Queue processor tracker
    class QueueProcessorTracker < BaseTracker


      def initialize(name, message)
        super(name)
        @doc['message'] = message
        
      end
      

      
    end
  end
end