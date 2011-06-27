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
          self.where(options).all
        end

        #Override paginate method - paginating apply only non-terminated objects
        def paginate(options = {})
          options.merge!(:state => {'$nin' => [:terminated]}) unless options.has_key? :state
          super(options)
        end

        #Override .all class method - all method return only non-terminated objects
        def where(options = {})
          options.merge!(:state => {'$nin' => [:terminated]}) unless options.has_key? :state
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

