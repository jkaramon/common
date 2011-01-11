module MongoMapper
  module Plugins
    module ActivesOrSelf

     module ClassMethods

        def self.actives
          raise "Not Implemented. Implement in inheritor"
        end

        def actives_or_self(entity)
          ret = self.actives.all
          ret << entity unless entity.nil? || entity.active?
          ret
        end
      end

      module InstanceMethods

        def active?
          raise "Not Implemented. Implement in inheritor"
        end

      end
    end
  end
end