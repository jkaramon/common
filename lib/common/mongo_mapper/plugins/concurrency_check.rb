class ConcurrencyError < StandardError

end

module MongoMapper
  module Plugins
    module ConcurrencyCheck
      
      
      def self.configure(model)
        model.class_eval do
          key :_timestamp, String
          before_save :_check_concurrency
        end
      end

     

      module ClassMethods
        def generate_timestamp
          tnow = Time.now.utc
          "#{tnow.to_i}#{tnow.tv_usec}"
        end
        
        # Can be overriden by each class
        # By default, disables concurrency check if running in job server mode
        def disable_concurrency_check?
          ENV['JOB_SERVER'] == "1"
        end
          
        
      end

      module InstanceMethods
        def _check_concurrency
          return if self.class.disable_concurrency_check?
          actual_version = self.class.find(self.id)
          
          unless actual_version.try(:_timestamp).nil?
            raise ConcurrencyError unless self._timestamp == actual_version._timestamp
          end
          self._timestamp = self.class.generate_timestamp
        end
      end
    end
  end
end

