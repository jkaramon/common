module MongoMapper
  module Plugins
    module BasicEntityState

      def self.configure(model)
        model.class_eval do
          plugin MongoMapper::Plugins::StateTerminated

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

          scope :actives, :state => :active
        end
      end

      module ClassMethods

        def actives_or_self(entity)
          ret = self.actives.all
          ret << entity unless entity.nil? || entity.state == "active"
          ret
        end
      end

      module InstanceMethods
      end

    end
  end
end

