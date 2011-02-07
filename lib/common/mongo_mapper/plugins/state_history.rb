require_relative '../models/state_history_record'

module MongoMapper

  module Plugins
    # Plugin stores all state changes in array of MongoMapper::Models::StateHistoryRecord embedded document.
    # History is accessible via state_history_records attribute
    module StateHistory 

      def self.configure(model)
        model.class_eval do
          many :state_history_records, :class_name => '::MongoMapper::Models::StateHistoryRecord'        
        end
      end

      module ClassMethods

      end

      module InstanceMethods

        def update_state_history(transition)

          # add state history tracking
          record = ::MongoMapper::Models::StateHistoryRecord.create(transition, _current_user_id)
          if record.state_changed?
            # append state change
            self.push({ :state_history_records => record.to_mongo })
            self.state_history_records << record
          end

        end


        def _current_user_id
          return self.current_user.try(:id) if self.respond_to?(:current_user)
          nil
        end
      end

    end
  end
end


