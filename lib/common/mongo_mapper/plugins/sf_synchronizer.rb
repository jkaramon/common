
module MongoMapper
  module Plugins
    module SfSynchronizer

      def self.configure(model)
        model.class_eval do
          after_save :base_synchronize
        end
      end

      module ClassMethods
        
      end

      module InstanceMethods

        def base_synchronize
          super
        end

        def synchronize_entity(collection, attr, sf_attr, sf_value)
          db = MongoMapper.database
          coll = db[collection]
          coll.update({attr => self.id}, {"$set" => {sf_attr => sf_value} }, :multi => true)
        end

      end

    end
  end
end