require 'mongo_mapper'

module MongoMapper
  module Plugins
    module Patches
      extend ActiveSupport::Concern

      # MongoMapper patches
      module ClassMethods

        # Patch - do not create index now, we do not know database yet ...
        def ensure_index(name_or_array, options={})
          keys_to_index = if name_or_array.is_a?(Array)
                            name_or_array.map { |pair| [pair[0], pair[1]] }
                          else
                            name_or_array
                          end
          # TODO: add index creation responsibility to the DbManager
          # collection.create_index(keys_to_index, options[:unique])
        end


       

      end

    end


  end  
end


MongoMapper::Document.plugin(MongoMapper::Plugins::Patches)
