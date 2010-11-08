module Messaging
  
  class Queue 
    include MongoBackend  
    attr_reader :name
    def initialize(queue_name)
      @name = queue_name
    end

  end


end
