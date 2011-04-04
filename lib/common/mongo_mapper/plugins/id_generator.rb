
module MongoMapper
  module Plugins

    # Provides integer based human_id and custom formattable id for given collection
    module IdGenerator
      DEFAULT_ID_FORMAT = "%05d"
      DEFAULT_ID_PARSE_FORMAT = "\d{5}"


      def self.configure(model)
        model.class_eval do
          key :human_id, Integer
          key :human_id_formatted, String
          before_save :_set_human_id_callback
        end
      end

      module ClassMethods
        # Allows defining id structure (prefix, number length, suffix)
        # uses sprintf format 
        def id_format(id_format)
          @id_format = id_format
        end

        def _id_format
          @id_format
        end


        # Defines, how human_id_formatted can be parsed
        # @id_parse_format [String] - reqular expression pattern to parse human_id_formatted
        def id_parse_format(id_parse_format)
          @id_parse_format = id_parse_format
        end

        def id_parse_format
          @id_parse_format || DEFAULT_ID_PARSE_FORMAT
        end
        
        def _format_human_id(human_id)
          format = DEFAULT_ID_FORMAT
          format = self._id_format unless self._id_format.blank?
          sprintf( format, human_id) 
        end



        # generates and return a new human_id
        def generate_current_id
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

        # resets counter for current class
        def reset_counter
          db = MongoMapper.database
          coll = db["entity_counters"]
          coll.remove({"id" => self.to_s()})
        end
      end

      module InstanceMethods
        # after save callback
        def _set_human_id_callback
          # do not assign id in draft state
          return if self.respond_to?(:draft?) and self.draft? 
          set_human_id if self.human_id.nil? 
        end

        # assigns new human id 
        def set_human_id
          new_id = self.class.generate_current_id
          new_id_formatted = self.class._format_human_id(new_id)
          self.human_id = new_id        
          self.human_id_formatted = new_id_formatted
        end


      end

    end
  end
end

