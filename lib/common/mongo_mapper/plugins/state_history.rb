require_relative '../models/state_history_record'

module MongoMapper

  module Plugins
    # Plugin stores all state changes in array of MongoMapper::Models::StateHistoryRecord embedded document.
    # History is accessible via state_history_records attribute
    module StateHistory 

      def self.configure(model)
        model.class_eval do
          after_initialize :_init_state_history          
        end
      end

      module ClassMethods

      end

      module InstanceMethods
        
        def _init_state_history
          # return if class does not support state_machine for :state attribute
          return if !self.class.respond_to?(:state_machines) || !self.class.state_machines.include?(:state)
          # return if plugin is already initialized for this instance 
          return if self.respond_to?(:state_history_records)
          
          self.class_eval do
            many :state_history_records, :class_name => '::MongoMapper::Models::StateHistoryRecord'
          end

          after_transition_callback = StateMachine::Callback.new(:after)  do |entity, transition|
            # add state history tracking
            record = ::MongoMapper::Models::StateHistoryRecord.create(transition, _current_user_id)
            if record.state_changed?
              # append state change
              entity.class.push(entity.id, { :state_history_records => record.to_mongo })
              state_history_records << record
            end
            
          end
          self.class.state_machines[:state].callbacks[:after] << after_transition_callback
        end


        def _current_user_id
          return self.current_user.try(:id) if self.respond_to?(:current_user)
          nil
        end
      end

    end
  end
end


