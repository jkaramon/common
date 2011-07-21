module MongoMapper
  module Plugins
    module CustomFieldType
      extend ActiveSupport::Concern
      included do
        many :field_definitions, :class_name => 'CustomFields::Definition'
        validates_associated :field_definitions
      end


    end
  end
end


