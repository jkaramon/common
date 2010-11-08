module Rack
  class MongoMapperCleanup
    def initialize app, options = {}
      @app = app
      @options = options
    end  

    def call env
      if Rails.configuration.cache_classes 
        MongoMapper::Plugins::IdentityMap.clear 
      else 
        MongoMapper::Document.descendants.clear 
        MongoMapper::Plugins::IdentityMap.models.clear 
      end 
      return @app.call env
    end
    
  end
end