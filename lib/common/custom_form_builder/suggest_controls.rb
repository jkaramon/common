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
      template.content_tag :span, result, :class => "suggest_container #{wrapper_class} s_#{method.to_s}", "data-id_value" => id
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
    
    def person_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_person'
      options[:input_html][:title] = suggest_title(Person)
      options[:input_html][:class] = 'suggest_person can_create' if template.can?(:create, Person)
      suggest_input(method, options)
    end

    def customer_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_customer'
      options[:input_html][:title] = suggest_title(Customer)
      suggest_input(method, options)
    end
    
    def solver_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_solver'
      options[:input_html][:title] = suggest_title(Person)
      suggest_input(method, options)
    end
    
    def ticket_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_ticket'
      options[:input_html][:title] = suggest_title(Ticket)
      suggest_input(method, options)
    end

    def kb_suggest_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_kb'
      options[:input_html][:title] = suggest_title(Kb)
      suggest_input(method, options)
    end
    
    def configuration_item_type_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_configuration_item_type'
      options[:input_html][:title] = suggest_title(ConfigurationItemType)
      suggest_input(method, options)
    end
    
    def configuration_item_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_configuration_item'
      options[:input_html][:title] = suggest_title(ConfigurationItem)
      suggest_input(method, options)
    end
    
    def request_template_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_request_template'
      options[:input_html][:title] = suggest_title(RequestTemplate)
      suggest_input(method, options)
    end
    
    def category_input(method, options)
      options[:input_html] ||= {}
      assoc_name = method.to_s.sub(/_id$/, '')
      options[:input_html][:value] = object.send(assoc_name).try(:full_name)
      options[:input_html][:class] = 'suggest_category'
      options[:input_html][:title] = suggest_title(Category)
      suggest(method, options, get_rule(method).visibility) <<
      template.content_tag(:span, '', :class => 'kb_icon')
    end

    def actor_input(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] = 'suggest_actor'
      options[:input_html][:title] = suggest_title(Actor)
      suggest_input(method, options)
    end

    def tag_suggest_input(method, options)
      select_options = {}
      select_options[:multiple] = true
      select_options[:name] = "#{object_name}[#{method}]"

      select_options[:id] = "#{object_name}_#{method}"

      options[:input_html] ||= {}
      options[:wrapper_html] ||= {}

      options[:wrapper_html][:class] = 'tag_suggest'
      options[:input_html][:title] = suggest_title(Kb)
      input(method, options)

      label = self.label(method, options_for_label(options)) 
      option_tags = ""
      object.tags.each do |tag|
        option_tags << template.content_tag(:option, tag, :selected => true, :value => tag)
      end
      label + template.content_tag(:select, option_tags, select_options)
    end

  end
end