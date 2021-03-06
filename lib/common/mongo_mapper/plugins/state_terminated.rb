module MongoMapper
  module Plugins
    module StateTerminated
      extend ActiveSupport::Concern
      #Plugin extends state machine of included model
      #Object go to terminated state instead of remove from database

      module ClassMethods

        #Override .all class method - all method return only non-terminated objects
        def all(options = {})
          super(prepare_options(options))
        end

        #Override paginate method - paginating apply only non-terminated objects
        def paginate(options = {})
          super(prepare_options(options))
        end

        #Override .where class method - all method return only non-terminated objects
        def where(options = {})
          super(prepare_options(options))
        end

        #Override .first class method - all method return only non-terminated objects
        def first(options = {})
          super(prepare_options(options))
        end

        private

        def prepare_options(options)
          return options.merge(:state => {'$nin' => [:terminated]}) unless options.has_key? :state
          options
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

