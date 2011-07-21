# encoding: utf-8
module Messaging
  
  class Queue 
    include MongoBackend  
    attr_reader :name
    attr_reader :options
    def initialize(queue_name, options = {})
      @name = queue_name
      @options = options || {}
    end

  end


end
