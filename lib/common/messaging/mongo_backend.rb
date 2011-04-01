module Messaging
  
  module MongoBackend
    attr_accessor :test_env 
    def enqueue(data)
      message = Message.create(data)
      message[:queue_name] = name
      collection.insert(message)      
    end
    
    def dequeue_message
      message = collection.find_and_modify(
        :query => {:status => "inserted" },
        :sort => ["create_date", :desc], 
        :update => { '$set' => { :status => "processed" } },
        :check_response => false
      )
      
      if message
        message = HashWithIndifferentAccess.new.merge(message)
      end
      collection.remove({ :status => "processed" })
      message
      rescue Mongo::OperationFailure
        nil
    end

    def dequeue
      message = dequeue_message
      message.nil? ? nil : message['data'] 
    end

    def delete
      collection.remove
    end
    
    alias :clear :delete
    

    


    def database
      @database = MongoMapper.connection.db("messaging#{env_suffix}")
    end
    
    private

    def env_suffix
      return "-gem-development" unless defined?(Rails)
      if env=="production" || env=="preprod"
        return "-preprod" if options[:route_to] == :beta
        return "" if options[:route_to] == :stable
      end
      return "" if env=="production"
      return "-development" if %w{ development devcached }.include?(env)
      "-#{env}"  
    end

    def env
      @test_env || Rails.env
    end

    
    
    def collection
      @collection ||= database.collection("queue_#{name}")
    end
    
  end
  
end
