# hidden input for _timestamp should be included in forms and should be sent to the server
# this value should be assigned to an entity and then the concurrency check comparison on update action can be done

module MongoMapper
  module Plugins
    module ConcurrencyCheck
      extend ActiveSupport::Concern

      included do
        key :_timestamp, String
        validate :_check_concurrency, :on => :update

        before_save do
          self._timestamp = self.class.generate_timestamp
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

        def set_timestamp
          self._timestamp = self.class.generate_timestamp
        end

        def update_attributes(params)
          _guard_timestamp_param(params)
          super
        end

        def _guard_timestamp_param(params)
          return if self.new? || self._timestamp.blank?
          raise "_timestamp parameter is required" unless params.include?(:_timestamp)
          raise "_timestamp parameter is present but is blank." if params[:_timestamp].blank?        
        end

        def _check_concurrency
          return if self.new? || self.class.disable_concurrency_check?
          actual_version = self.class.find(self.id)

          if actual_version.try(:_timestamp).present? and self._timestamp != actual_version._timestamp
            self.trigger_concurrency_check_error
          end

        end


        def trigger_concurrency_check_error
          self.errors.add(:base, "#{self.class.human_name} has been modified by someone else! Try reopen it and save again.")
        end

      end
    end
  end
end

