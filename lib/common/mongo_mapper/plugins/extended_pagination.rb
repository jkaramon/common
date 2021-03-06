module MongoMapper
  module Plugins
    module ExtendedPagination
      extend ActiveSupport::Concern


      module ClassMethods

        # Enhances pagination to return total records in options hash
        def paginate(options)
          mongo_query = {}
          mongo_query.merge!(options)
          mongo_query.delete(:page)
          mongo_query.delete(:per_page)
          total_records = self.count(mongo_query)
          result = query.paginate({:per_page => per_page}.merge(options))
          options[:records] = total_records
          result
        end




      end

    end
  end
end




