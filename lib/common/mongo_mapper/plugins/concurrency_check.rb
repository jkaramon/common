module MongoMapper
  module Plugins
    module ConcurrencyCheck
      def self.configure(model)
        model.class_eval do
          key :last_update, Float, :default => Time.now.utc.to_f

          before_save :_check_concurrency
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def _check_concurrency
          actual_version = self.class.find(self.id)
          unless actual_version.nil?
            raise "Document has been modified" unless self.last_update == actual_version.last_update
          end
          self.last_update = Time.now.utc.to_f
        end
      end
    end
  end
end