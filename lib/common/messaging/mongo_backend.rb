module Messaging
  
  module MongoBackend
    
    def enqueue(data)
      message = Message.create(data)
      message[:queue_name] = name
      collection.insert(message)      
    end
    
    def dequeue_message
      message = collection.find_and_modify(
        :query => {:status => "inserted" },
        :sort => ["create_date", :desc], 
        :update => { '$set' => { status: "processed" } },
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
    
    private 


    def database
      @database ||= MongoMapper.connection.db("messaging#{env_suffix}")
    end

    def env_suffix
      return "-gem-development" unless defined?(Rails)
      env_suffix = ""
      env_suffix = "-#{Rails.env}" unless Rails.env.production?
      env_suffix
    end
    
    def collection
      @collection ||= database.collection("queue_#{name}")
    end
    
  end
  
end
