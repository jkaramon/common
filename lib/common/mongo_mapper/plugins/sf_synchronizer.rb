# should synchronize selected attributes with search fields (sf_****) on related entities
# example: changing category name should reflect in sf_category - attribute on all tickets

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

        # reimplemented in specific classes
        # should call method synchronize_entity for all sf fields and all related entities
        def base_synchronize
          super
        end

        # updates all documents in 'collection', which attribute 'attr' is set to entity id
        # updates only search field "sf_attr" with new value "sf_value"
        def synchronize_entity(collection, attr, sf_attr, sf_value)
          db = MongoMapper.database
          coll = db[collection]
          coll.update({attr => self.id}, {"$set" => {sf_attr => sf_value} }, :multi => true)
        end

      end

    end
  end
end