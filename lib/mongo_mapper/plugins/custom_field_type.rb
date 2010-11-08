module MongoMapper
  module Plugins
    module CustomFieldType

      def self.configure(model)
        model.class_eval do
          many :field_definitions, :class_name => 'CustomFields::Definition'
          validates_associated :field_definitions
        end
      end

    end
  end
end


