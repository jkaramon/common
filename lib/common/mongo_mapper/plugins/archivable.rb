require 'bson'

module MongoMapper
  module Plugins
    module Archivable
      extend ActiveSupport::Concern

      included  do
        key :entity_id
        before_destroy :save_to_archive
      end

      module ClassMethods

        def archived_count
          old_db_name = MongoMapper.database.name
          db_name = "#{old_db_name}-archive"
          count = 0
          begin
            MongoMapper.database = db_name
            count = self.count
          ensure
            MongoMapper.database = old_db_name
          end
          count
        end

      end

      module InstanceMethods

        def save_to_archive
          old_db_name = MongoMapper.database.name
          db_name = "#{old_db_name}-archive"
          begin
            MongoMapper.database = db_name
            self.entity_id = self._id
            self._id = BSON::ObjectId.new
            self.save(:validate=>false)
          ensure
            MongoMapper.database = old_db_name
            self._id = self.entity_id
          end

        end
      end

    end
  end
end
