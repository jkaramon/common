module MongoMapper
  module Plugins
    module ConcurrencyCheck
      def self.configure(model)
        model.class_eval do
          key :_timestamp, String, :default => generate_timestamp
          before_save :_check_concurrency
        end
      end

     

      module ClassMethods
        def generate_timestamp
          tnow = Time.now.utc
          "#{tnow.to_i}#{tnow.tv_usec}"
        end

      end

      module InstanceMethods
        def _check_concurrency
          actual_version = self.class.find(self.id)
          unless actual_version.nil?
            raise "Document has been modified" unless self._timestamp == actual_version._timestamp
          end
          self._timestamp = self.class.generate_timestamp
        end
      end
    end
  end
end
