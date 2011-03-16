module Jobs
  module Tracking
    # MongoDB Base JobTracker
    class BaseTracker

      attr_accessor :name
      attr_reader :status, :status_description

      def initialize(name)
        @name = name
        @doc = tracker_doc_template
        @status = @doc[:status]
        @collection_exists = false
      end

      def ensure_collection_exists
        return if @collection_exists
        collection.save(@doc)
        @collection_exists = true
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
        
        update( { "$push" => { "log" => log_entry(message, severity) } })
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
        return unless @collection_exists
        @status = :ok
        update( {"$set" => {"status" => @status.to_s} } )
      end

      def set_error!(err)
        return unless @collection_exists
        @status = :error
        @status_description = err
        update( {"$set" => {"status" => @status.to_s, "status_description" => err} } )
      end

      def update(cmd)
        ensure_collection_exists
        collection.update( me_selector, cmd )
      end


      def database
        @database ||= MongoMapper.connection.db("jobs#{env_suffix}")
      end

      def env_suffix
        return "-gem-development" unless defined?(Rails)
        return DbManager.db_suffix
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
