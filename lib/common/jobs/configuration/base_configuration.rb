module Jobs
  module Configuration
    class BaseConfiguration
      
      attr_accessor :name
      attr_accessor :site_id
      
      def initialize(name, site_id)
        @name = name
        @site_id = site_id
        @doc = doc_template
      end

      def save!
        collection.save(@doc)
      end

      def doc_template
        {
          :site_id => site_id,
          :name => name,
          :process => false
        }
      end

      def self.set_process!(name, site_id)
        self.collection(name).update( {'name'=>name, 'site_id'=>site_id}, {"$set" => {"process" => "true"} } )
      end

      def self.set_not_process!(name, site_id)
        self.collection(name).update( {'name'=>name, 'site_id'=>site_id}, {"$set" => {"process" => "false"}} )
      end

      def self.find_by(name, site_id)
        return collection(name).find_one(:name => name, :site_id => site_id)
      end

      
      def database
        @database ||= MongoMapper.connection.db("jobs#{env_suffix}")
      end

      def env_suffix
        return "-gem-development" unless defined?(Rails)
        env_suffix = ""
        env_suffix = "-#{Rails.env}" unless Rails.env.production?
        env_suffix
      end


      def collection_name
        "#{name}_configuration"
      end
      
      def collection
        @collection ||= database.collection(collection_name)
      end

      def self.collection(name)
        @collection ||= database.collection("#{name}_configuration")
      end

      def self.database
        @database ||= MongoMapper.connection.db("jobs#{env_suffix}")
      end

      def self.env_suffix
        return "-gem-development" unless defined?(Rails)
        env_suffix = ""
        env_suffix = "-#{Rails.env}" unless Rails.env.production?
        env_suffix
      end

    end
  end
end