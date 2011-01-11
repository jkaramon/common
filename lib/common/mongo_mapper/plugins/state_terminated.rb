
module MongoMapper
  module Plugins
    module StateTerminated

      def self.configure(model)
      end

      module ClassMethods

        def all(options = {})
          self.where(:state => {'$nin' => [:terminated]}).all(options)
        end
        
      end

      module InstanceMethods
        def do_terminate
          self.state = :terminated
          save
        end

        def do_terminate!
          self.state = :terminated
          save!
        end
      end

    end
  end
end

