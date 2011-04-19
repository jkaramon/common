module CustomFormBuilder
  # Nested form implementation was stolen from these examples:
  # http://railscasts.com/episodes/196-nested-model-form-part-1,
  # http://railscasts.com/episodes/197-nested-model-form-part-2.
  # 
  # Javascript support is already implemented in application.js
  # 
  # @example Usage (assuming that root document (Ticket) has many workarounds):
  #   <!-- Render existing workaround -->
  #   <% form.semantic_fields_for :workarounds, form.object.workarounds do |workaround_form| %>
  #     <%= workaround_form.nested_partial 'shared/workaround'  %>
  #   <%- end %> 
  #   <!-- Render add new workaround button -->
  #   <%= form.add_nested_child :workarounds %>
  #   <!-- Render hidden workaround partial -->
  #   <%= form.new_child_fields_template(:workarounds, Workaround, :partial => 'shared/workaround' )%>
  module NestedForms
    # @param [Symbol] association association name as defined in root document
    # @param [Class] association_class type of the associated entities 
    # @param [Hash] options 
    # @option options :object (association_class.new) object used to build nested partial 
    # @option options :partial_name (association.to_s.singularize) nested partial to render
    # @return hidden child partial 
    def new_child_fields_template(association, association_class, options = {})
      options[:object] ||= association_class.new
      options[:partial] ||= association.to_s.singularize
      template.content_tag(:fieldset, :id => "#{association}_fields_template", :style => "display: none") do
        template.semantic_fields_for(association, options[:object], :index => "new_#{association}") do |f|
          
          nested_partial(options[:partial], :form => f)
        end
      end
    end
    
    
    # Used in nested partial to render remove buton which removes nested entity
    # @param [Hash] options 
    # @option options [String] :caption ('remove') Link text
    # @return renders remove link on a child entity
    def remove_nested_child(options = {})
      options[:caption] ||= ::I18n.t('remove')
      hidden_field(:_delete) + template.link_to(options[:caption], "javascript:void(0)", :class => "remove_nested_child button")
    end

    # @param [Hash] options 
    # @option options [String] :caption ('add') Link text
    # @return renders add new child entity link
    def add_nested_child(association, options = {})
      options[:caption] ||= ::I18n.t('add')
      template.link_to(options[:caption], "javascript:void(0)", :class => "add_nested_child button", :"data-association" => association, :"data-parent" => object.class.to_s.underscore.gsub("/", "_") )
    end
  end
end
