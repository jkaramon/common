module MongoMapper
  module Plugins
    module CustomField
      extend ActiveSupport::Concern

      included do
        key :type_id, ObjectId
        belongs_to :type, :class_name => self::CustomEntityClassName
        many :fields, :class_name => 'CustomFields::Field'
        validates_associated :fields
      end

      module InstanceMethods

        #Assigns entity_type and refreshes fields according to type specification
        def assign_type(entity_type)
          self.type = entity_type
          refresh_fields
        end

        def refresh_fields
          self.type.field_definitions.each do |definition|
            existing_field = fields.detect {|f| f.definition == definition}
            if existing_field
              existing_field.definition = definition
            else
              self.fields << CustomFields::Field.new(:definition => definition)
            end
          end unless self.type.nil?
          self.save :validate => false
        end

      end

    end
  end
end

