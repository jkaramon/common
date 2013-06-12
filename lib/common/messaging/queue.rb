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

    def database
      @database = MongoMapper.connection.db("messaging#{options[:env_suffix] || env_suffix}")
    end
 
  end


end
