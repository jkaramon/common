module MongoMapper
  module Plugins
    module Codelist
      extend ActiveSupport::Concern
      included do
        key :name, String, :required => true
        key :description, String
        key :sequence_id, Integer
        before_create :_init_sequence_id

      end

      module ClassMethods
      end

      module InstanceMethods

        def _init_sequence_id
          self.sequence_id = self.class.count+1
        end
      end

    end
  end
end


