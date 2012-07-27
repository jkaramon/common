module Jobs
  module Synchronization
    class FullText
      
      attr_accessor :name
      
      def initialize(name)
        @name = name
        ensure_collection_exists
      end

      def set_timestamp(timestamp)
        doc = {
          :name => @name,
          :timestamp => timestamp        
        }
        set_doc(@name, doc)
      end

      def get_timestamp
        doc = get_doc(@name)
        doc['timestamp'] || 0
      end

    private

      def database
        @database ||= MongoMapper.connection.db("local")
      end

      def collection_name
        "vd.synchronization#{env_suffix}"
      end

      def env_suffix
        return "-gem-development" unless defined?(Rails)
        env_suffix = ""
        env_suffix = "-#{Rails.env}" unless Rails.env.production?
        env_suffix
      end

      def ensure_collection_exists
        database.create_collection(collection_name)
      end
 
      def set_doc(name, doc)
        database.collection(collection_name).update( {'name' => name}, {"$set" => doc}, {:upsert => true} )
      end

      def get_doc(name)
        database.collection(collection_name).find_one( {'name' => name} )
      end
  
    end
  end
end
