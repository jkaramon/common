module MongoMapper
  module Plugins
    module StateTerminated

      #Plugin extends state machine of included model
      #Object go to terminated state instead of remove from database

      def self.configure(model)

        
      end

      module ClassMethods

        #Override .all class method - all method return only non-terminated objects
        def all(options = {})
          self.where(:state => {'$nin' => [:terminated]}).all(options)
        end

        #Override paginate method - paginating apply only non-terminated objects
        def paginate(options = {})
          options.merge!(:state => {'$nin' => [:terminated]})
          super(options)
        end
        
      end

      module InstanceMethods
        #move object to terminate state
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

