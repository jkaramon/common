# encoding: utf-8
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
        :sort => ["$natural", :asc], 
        :update => { '$set' => { :status => "processed" } },
        :check_response => false
      )
      
      if message
        message = HashWithIndifferentAccess.new.merge(message.deep_symbolize_keys)
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
      return ""                 if %w{ preprod production }.include?(env)
      return "-development"     if %w{ development devcached }.include?(env)
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
