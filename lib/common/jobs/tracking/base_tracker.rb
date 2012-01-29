module Jobs
  module Tracking
    # MongoDB Base JobTracker
    class BaseTracker

      attr_accessor :name
      attr_reader :status, :status_description, :data

      def initialize(name, data = {})
        @name = name
        @doc = tracker_doc_template
        @status = @doc[:status]
        @data = data
        ensure_collection_exists
      end

      def ensure_collection_exists
        database.create_collection(collection_name, :capped => true, :size => 100.megabytes, :autoIndexId => true )
      end
      

      def add_data(data_hash)
        @data.merge!(data_hash)
      end


      def tracker_doc_template
        {
          :name => name,
          :created_at => Time.now,
          :status => :inprogress,
          :log => []
        }

      end


      def info(message)
        log(message, :info)
      end

      def error(message)
        log(message, :error)
      end

      def warn(message)
        log( message, :warn)
      end

      def log(message, severity)
        
         @doc[:log] << log_entry(message, severity) 
      end

      def me_selector
        {'_id' => @doc[:'_id'] }
      end

      def log_entry(message, severity)
        {
          :created_at => Time.now,
          :message => message,
          :severity => severity.to_s
        }
      end

      def set_success!
        @status = :ok
        return if @doc[:log].blank?
        insert unless @doc[:status].blank?
      end

      def set_error!(err)
        @status = :error
        @status_description = err
        insert
      end

      def insert
        @doc[:status] = @status.to_s
        @doc[:data] = @data
        @doc[:status_description] = @status_description if @status_description.present?
        collection.insert(  @doc )
      end


      def database
        @database ||= MongoMapper.connection.db("jobs#{env_suffix}")
      end

      def env_suffix
        return "-gem-development" unless defined?(Rails)
        return "-development" if %w{ development devcached }.include?(env)
        return "" if env=="production" || env =="preprod"
        "-#{env}" 
      end

      def env
        Rails.env
      end

     
      def collection_name
        "#{name}_tracker"
      end
      
      def collection
        @collection ||= database.collection(collection_name)
      end
    end

  end
end
