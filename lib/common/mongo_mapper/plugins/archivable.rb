module MongoMapper
  module Plugins
    module Archivable

      def self.configure(model)
        model.class_eval do
          key :entity_id
          before_destroy :save_to_archive
        end
      end

      module InstanceMethods

        def save_to_archive
          old_db_name = MongoMapper.database.name
          db_name = "#{old_db_name}-archive"

          MongoMapper.database = db_name
          self.entity_id = self._id

          require 'bson'
          self._id = BSON::ObjectId.new
          self.save(:validate=>false)
          MongoMapper.database = old_db_name
          self._id = self.entity_id

        end
      end

    end
  end
end
