module MongoMapper
  module Plugins
    module BasicEntityState
      extend ActiveSupport::Concern
      included do
        plugin MongoMapper::Plugins::StateTerminated
        plugin MongoMapper::Plugins::ActivesOrSelf
        plugin StateMachine::Internationalization

        state_machine :initial => :draft do

          before_transition :draft => any - [:draft] do |entity, transition|
            entity.set_human_id if entity.respond_to?(:set_human_id) && entity.try(:human_id).nil?
          end

          event :do_activate do
            transition [:inactive] => :active
          end

          event :do_deactivate do
            transition [:active] => :inactive
          end

          event :do_save do
            transition [:active, :inactive] => same
          end

          event :do_create do
            transition [:draft] => :active
          end

          event :do_terminate do
            transition [:active, :inactive] => :terminated
          end


        end


      end

      module ClassMethods

        def actives
          where(:state => :active)
        end

      end

      module InstanceMethods

        def active?
          self.state == 'active'
        end

        def partial_action(action)
          to_state = self.state_transitions.select{ |x| x.event == action }.first.try(:to)
          if to_state.present?
            self.state = to_state
            doc = partial_action_data(action, to_state)
            doc[:state] = to_state
            self.set(doc)
          end
        end

      protected
        def partial_action_data(action = nil, new_state = nil)
          {}
        end

      end

    end
  end
end

