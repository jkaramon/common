# encoding: utf-8
module Messaging
  class Message < Hash

    def self.create(data)
      { 
        :status => "inserted", 
        :create_date => Time.now, 
        :data => data 
      }
    end


  end
end
