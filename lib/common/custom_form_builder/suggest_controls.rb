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
      if state==:disabled
        text_input = disabled_content(method, :input_html => {:value => text,:class=>summary,"data-summary_length"=>summary_length })
      else
        options[:input_html] = {}

        text_input = text_field(attr_id, options.merge(:value => text, :class => summary,"data-summary_length"=>summary_length)).gsub(/_id/, '_text')
      end
      result = self.label(method, options_for_label(options)).gsub(/_id/, '_text') << text_input
      template.content_tag :span, template.raw(result), :class => "suggest_container #{wrapper_class} s_#{method.to_s}", "data-id" => id
    end
    
    def suggest_title(klass)
      template.suggest_title(klass)
    end
    
    def suggest_detail_icon
      template.content_tag :a, nil, :href => '#', :class => 'ui-icon ui-icon-info ui-state-disabled detail_button', :tabIndex => -1
    end
    
    def suggest_add_icon(state)
      return "" if state==:disabled
      template.content_tag :a, nil, :href => '#', :class => 'ui-icon ui-icon-circle-plus ui-state-disabled add_button', :tabIndex => -1
    end
  
  end
end
