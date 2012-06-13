
module MongoMapper
  module Plugins

    # Provides integer based human_id and custom formattable id for given collection
    module IdGenerator
      extend ActiveSupport::Concern
      included do
        key :human_id, Integer
        key :human_id_formatted, String
        before_save :_set_human_id_callback

        def self.find!(id)
          raise DocumentNotFound, "Couldn't find without an ID" if id.nil?
          result = self.find(id) 
          raise DocumentNotFound, "Couldn't find by human_id or id!" if result.nil?
          result
        end

        # reimplement find method to enable find by human id
        def self.find(id)
          return nil if id.nil?
          human_id = parse_human_id_formatted(id)
          result = nil
          if human_id.present? 
            results = all(:human_id => human_id)           
            case results.count
            when 0
            when 1
              result = results.first
            else
              ids = results.map { |r| { id: r.id, human_id_formatted: r.human_id_formatted }}
              raise "More than one result found for model '#{self.inspect}'. Raw id: #{id}, parsed id: #{human_id}.\nResults: #{ids.inspect}"
            end
          end
          result = first(:_id => id) if result.nil? 
          result
        end


      end


      DEFAULT_ID_FORMAT = "%05d"



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
        # @id_parse_format [RegExp] - reqular expression pattern to parse human_id_formatted
        def id_parse_format(id_parse_format)
          @id_parse_format = id_parse_format
        end

        def _id_parse_format
          if @id_parse_format.nil?
            raise "Model '#{self.inspect}' includes IdGenerator plugin, but does not define required 'id_parse_format' class method"
          end
          @id_parse_format
        end

        def _format_human_id(human_id)
          format = DEFAULT_ID_FORMAT
          format = self._id_format unless self._id_format.blank?
          sprintf( format, human_id) 
        end

        # returns array of human ids parsedf from input text
        def parse_human_ids_formatted(input)
          return [] unless input.respond_to?(:scan)
          pattern = self._id_parse_format
          input.scan(pattern)
          .map(&:first)  # Each capture is returned as array, get its first element
          .map(&:to_i)   # Convert it to integer human_id 

        end

        #returns first human_id parsed from input text
        def parse_human_id_formatted(input)
          parse_human_ids_formatted(input).first
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


        def to_param
          human_id_formatted
        end





        # assigns new human id 
        def set_human_id
          new_id = self.class.generate_current_id
          self.human_id = new_id   
          update_human_id_formatted
        end

        def update_human_id_formatted
          self.human_id_formatted = self.class._format_human_id(self.human_id)
          self
        end


      end

    end
  end
end

