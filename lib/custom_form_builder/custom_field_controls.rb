module CustomFormBuilder

  module CustomFieldControls
    # Defines available meta_fields
    # @see CustomFields::MetaFields::Base
    def meta_field_type
      options = CustomFields::MetaFields.all_classes.collect do |klass|
        selected = "selected='selected'" if  object.meta_field.class == klass
        "<option value='#{klass.to_s}' #{selected}>#{klass.human_name}</option>"
      end 
      
      template.content_tag :li, template.label_tag("meta_field_type") <<
      template.raw(template.select_tag("meta_field_type", template.raw(options), :class => :meta_field_type))
      
    end
  end
end
