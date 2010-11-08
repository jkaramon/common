module CustomFormBuilder
  ##
  # State aware controls - buttonizer, state_select ... 
  module StateControls
    
    
    
    def state_buttonizer(options = {})
      hidden_events = options[:hide_events] || []
      css_class = options[:class] || 'state_buttonizer'
      generate_hidden_field = options[:generate_hidden_field] || !options.has_key?(:class)
      root = object
      root = object._root_document if object.respond_to?(:_root_document) && object._root_document.present?      
      
      root_controller = root.class.to_s.tableize
      
      fields = @object.state_events.inject("") do |memo, event_name|
        if hidden_events.include?(event_name)
          memo += ""
        else
          memo += template.tag(:input, { 
            :type => :button, 
            'data-event_name' => event_name, 
            'data-root' => root_controller, 
            'data-root_id' => root.id,
            'data-entity_id' => object.id,
            :value => ::I18n.t("activemodel.state_events.#{event_name}"),
            :class => css_class
          }) 
        end
      end
      hidden = template.tag(:input, { :type => :hidden, :name => :state_event, :id => :state_event_field })
      return fields unless generate_hidden_field
      template.raw(fields + hidden)
    end
    
    
    def implicit_state_events_select(options = {})
      hidden_events = options[:hide_events] || []
      options[:selected_event] ||= ""
      option_list = @object.event_types.inject("") do |memo, event_type|        
        if hidden_events.include?(event_type.name)
          memo += ""
        else
          html_options = {:value => event_type.name,
            :title => event_type.description,
            'data-name' => event_type.name, 
            'data-caption' => event_type.caption, 
            'data-actions' => event_type.actions.join('|')
          }
          html_options[:selected] = 'selected' if event_type.name.to_s == options[:selected_event].to_s
          memo += template.content_tag(:option, event_type.caption, html_options )
        end 
      end    
      content = template.content_tag(:label, ::I18n.t("activemodel.state_events_label") ) <<
      template.content_tag(:select, template.raw(option_list), :class => :state_events_select) <<
      template.tag(:input, { :type => :hidden, :name => :state_event, :id => :state_event_field })
      template.content_tag :li, content
    end
    
    def state_events_select(options = {})
      hidden_events = options[:hide_events] || []
    
      option_list = @object.state_transitions.inject("") do |memo, transition|
        if hidden_events.include?(transition.event)
          memo += ""
        else
          memo += template.content_tag(:option, ::I18n.t("activemodel.state_events.#{transition.event}"), { 
            :value => transition.event, 
            "data-type" => ActivityTypeMapper.get(transition, object),
            "data-from_state" => transition.from_name,
            "data-to_state" => transition.to_name
          })
        end 
      end
      content = template.content_tag(:label, ::I18n.t("activemodel.state_events_label") ) <<
      template.content_tag(:select, option_list, :class => :state_events_select) << 
      template.tag(:input, { :type => :hidden, :name => :state_event, :id => :state_event_field })
      template.content_tag :li, content
    end
  end
end
