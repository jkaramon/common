
module MongoMapper
  module Plugins
    module StateTerminated

      def self.configure(model)
      end

      module ClassMethods
        def all(options = {})
          arr = self.where(options).all
          ret = arr.find_all{|item| item.state != 'terminated'}
          ret
        end
      end

      module InstanceMethods
        def do_terminate
          self.state = :terminated
          save!
        end
      end

    end
  end
end

