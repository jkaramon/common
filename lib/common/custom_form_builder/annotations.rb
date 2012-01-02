module CustomFormBuilder
  module Annotations

    def annotation_options(attribute, options = {})
      input_options = {}
      annotation = Validations::ClientAnnotation.new(object)
      required = options[:required].present? ? options[:required] == true  : annotation.required?(attribute)
      if required
        input_options['required'] = 'required'      
      end

      if options.include?(:placeholder)
        input_options['placeholder'] = options[:placeholder]
      else
        hint = annotation.hint(attribute) 
        input_options['placeholder'] = annotation.hint(attribute) if hint.present?
      end

      needs_validation = required

      presence_validations = annotation.validations_on(attribute, :kind => :presence )
      input_options['data-presence_message'] = validation_message(presence_validations)  if presence_validations.present?

      input_options['data-validate'] = true if needs_validation
      input_options
    end

    private


    def validation_message(validations) 
      messages = validations.map { |annotation| format_message(annotation) }
      messages.join("\n")
    end

    def format_message(annotation)
      "#{annotation[:attr_display_name]} #{annotation[:error]}"
    end

  end
end
