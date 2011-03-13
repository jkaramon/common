
module MongoMapper
  module Plugins
    module IdGenerator

      def self.configure(model)
        model.class_eval do
          key :human_id, Integer
          key :human_id_formatted, String
          before_save :_set_human_id_before_save
        end
      end

      module ClassMethods
        # Allows defining id structure (prefix, number length, suffix)
        def id_format(id_format)
          @id_format = id_format
        end

        def _id_format
          @id_format
        end

        def current_id
          db = MongoMapper.database
          coll = db["entity_counters"]

          items = coll.find("id" => self.to_s()).count()
          if items == 0
            doc = {"id" => self.to_s(), "count" => 1}
            coll.insert(doc)
          else
            coll.update( {"id" => self.to_s()}, {"$inc" => { "count" => 1 }} )
          end

          item = coll.find_one("id" => self.to_s())
          return item["count"]
        end

        # method for rspec tests
        def reset_counter
          db = MongoMapper.database
          coll = db["entity_counters"]
          coll.remove({"id" => self.to_s()})
        end
      end

      module InstanceMethods

        def _set_human_id_before_save
          if self.human_id.nil? and self.respond_to?(:state) && self.state != "draft"
            set_human_id
          end
        end

        def set_human_id
          self.human_id = self.class.current_id
          self.human_id_formatted = sprintf(self.class._id_format, self.human_id) unless self.class._id_format.blank?
        end

      end

    end
  end
end

