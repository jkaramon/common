

module MongoMapper
  module Plugins
    module ConcurrencyCheck


      def self.configure(model)
        model.class_eval do
          key :_timestamp, String
          validate :_check_concurrency, :on => :update
        end
      end



      module ClassMethods
        def generate_timestamp
          tnow = Time.now.utc
          "#{tnow.to_i}#{tnow.tv_usec}"
        end

        # Can be overriden by each class
        # Default is false (enabled)
        def disable_concurrency_check?
          false  
        end


      end

      module InstanceMethods

        def _check_concurrency
          return if self.new? || self.class.disable_concurrency_check?
          actual_version = self.class.find(self.id)

          if actual_version.try(:_timestamp).present? and self._timestamp != actual_version._timestamp
            self.trigger_concurrency_check_error
          end
          self._timestamp = self.class.generate_timestamp
        end


        def trigger_concurrency_check_error
          self.errors.add(:base, "#{self.class.human_name} has been modified by someone else! Try reopen it and save again.")
        end

      end
    end
  end
end

