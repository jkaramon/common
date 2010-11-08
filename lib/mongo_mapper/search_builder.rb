
module MongoMapper
  # Plugin defines the search_name_key, which contains values from the keys defined in search_fields array. 
  # Plugin automatically updates this key on before save.
  module SearchBuilder
    def self.configure(model)
      model.class_eval do
        key :search_name, String
        before_save :_update_search_name
      end
    end

    module ClassMethods
      # Allows defining searched keys
      def search_fields (search_fields = [])
        @search_fields ||= search_fields
      end
    end

    module InstanceMethods
      
      protected
      # Before save callback. Updates value for the search_name key
      def _update_search_name
        self.search_name = self.class.search_fields.inject('|') { |memo, key|  memo.to_s + send(key).to_s + '|' }
      end

    end
  end  
end