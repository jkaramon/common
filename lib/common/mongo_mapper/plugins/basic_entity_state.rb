module MongoMapper
  module Plugins
    module BasicEntityState

      def self.configure(model)
        model.class_eval do
          plugin MongoMapper::Plugins::StateTerminated
          plugin MongoMapper::Plugins::ActivesOrSelf

          state_machine :initial => :draft do
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

      end

    end
  end
end

