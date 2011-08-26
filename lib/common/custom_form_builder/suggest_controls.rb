module CustomFormBuilder
  ##
  # All suggest (autocomplete based) controls goes here. 
  module SuggestControls
    # Generates generic suggest control
    #NEW SUGGEST METHODS

    def suggest_input(method, options)
      return suggest(method, options, get_rule(method).visibility)
    end

    def suggest(method, options, state)
      options[:input_html] ||= {}
      wrapper_class = options[:input_html].delete(:class);
      assoc_name = method.to_s.sub(/_id$/, '')
      text = object.send(assoc_name).try(:display_name)
      id = object.send(method)
      attr_id = "#{method}".to_sym
      options[:wrapper_html] ||= {}

      summary_options(options)
      summary = options[:input_html][:class]
      summary_length = options[:input_html]["data-summary_length"]

      text_input = ""
      textbox_options = options[:textbox_html] || {}
      textbox_options[:class] ||= ""
      textbox_options[:class] += summary
      textbox_options[:value] =  text
      textbox_options['data-summary_length'] = summary_length
      textbox_options['data-id'] = id

      if state==:disabled
        text_input = disabled_content(method, :input_html => textbox_options)
      else
        text_input = text_field(attr_id, textbox_options).gsub(/_id/, '_text')
      end
      result = self.label(method, options_for_label(options)).gsub(/_id/, '_text') << text_input
      template.content_tag :span, template.raw(result), :class => "suggest_container #{wrapper_class} s_#{method.to_s}", "data-id" => id
    end
    
    def suggest_title(klass)
      template.suggest_title(klass)
    end
    
     end
end
