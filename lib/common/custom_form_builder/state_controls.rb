module CustomFormBuilder
  ##
  # State aware controls - buttonizer, state_select ... 
  module StateControls

    def portal_state_buttonizer
      options = {}
      options[:custom_caption_mapper] = { :do_save => :do_add_comment }
      state_buttonizer_filter(options)  do |entity, event_name|  
        allowed_event = event_name == :do_save 
        allowed_event ||= event_name == :do_close && (entity.state == :resolved || entity.state == :completed)
        allowed_event ||= event_name == :do_close && (entity.is_a?(Tickets::Call))
        allowed_event ||= event_name == :do_reopen
        allowed_event ||= event_name == :do_customer_feedback
        allowed_event
      end
    end


    def state_buttonizer(options = {})
      hidden_events = options[:hide_events] || []
      state_buttonizer_filter(options) { |entity, event_name| !hidden_events.include?(event_name) }
    end



    def state_buttons(options = {})
      hidden_events = options[:hide_events] || []
      css_class = options[:class] || 'state_buttonizer'
      root = object
      root = object._root_document if object.respond_to?(:_root_document) && object._root_document.present?    

     
      root_controller = root.class.to_s.tableize
      klass = @object.class
      class_name = klass.to_s.underscore.gsub("/", ".")
      parent_class_name = klass.parent.to_s.underscore.gsub("/", ".")

      items = 1
      first_item = nil
      fields = @object.event_types.inject("") do |memo, event_type|
        event_name = event_type.name
        if !hidden_events.include?(event_name)
          event_caption_key = event_name
          if options.include?(:custom_caption_mapper) 
            mapper = options[:custom_caption_mapper]
            event_caption_key = mapper[event_name] if mapper.include?(event_name)
          end
          localized_event_name = ::I18n.t("activemodel.state_events.#{class_name}.#{event_caption_key}",
                                          :default => [ event_type.caption ])
          link = template.content_tag(:a, localized_event_name, { 
            'data-name' => event_type.name, 
            'data-caption' => event_type.caption, 
            'data-actions' => event_type.actions.join('|'),
            'data-event_name' => event_name,
            'data-root' => root_controller, 
            'data-event_header' => 
              ::I18n.t("activemodel.state_events.#{class_name}.headers.#{event_caption_key}", 
                :default => [ ::I18n.t("activemodel.state_events.#{parent_class_name}.headers.#{event_caption_key}", :default => localized_event_name) ]),
            'data-event_description' => 
              ::I18n.t("activemodel.state_events.#{class_name}.descriptions.#{event_caption_key}", 
                :default => [ ::I18n.t("activemodel.state_events.#{parent_class_name}.descriptions.#{event_caption_key}", :default => localized_event_name) ]),
            'data-root_id' => root.id,
            'data-entity_id' => object.id,
            :class => css_class
          }) 
          li = template.content_tag(:li, link)
          if items == 1
            first_item = link
          end
          memo += li
          items += 1
        else
          memo += ""
        end
        memo
      end
      
      second_ul = template.content_tag(:ul, template.raw(fields))

      hidden = template.tag(:input, { :type => :hidden, :name => :state_event, :id => :state_event_field })
      result = template.content_tag(:ul, template.content_tag(:li, template.raw( first_item + second_ul ), :class => 'first'), :class => 'sf-menu action_menu')
      template.raw(result + hidden)
    end



    def state_buttonizer_filter(options = {}, &predicate)
      hidden_events = options[:hide_events] || []
      css_class = options[:class] || 'state_buttonizer'
      css_class << ' button'
      generate_hidden_field = options[:generate_hidden_field] || !options.has_key?(:class)
      root = object
      root = object._root_document if object.respond_to?(:_root_document) && object._root_document.present?    

     
      root_controller = root.class.to_s.tableize
      klass = @object.class
      class_name = klass.to_s.underscore.gsub("/", ".")
      parent_class_name = klass.parent.to_s.underscore.gsub("/", ".")


      fields = @object.state_events.inject("") do |memo, event_name|
        if predicate.call(@object, event_name)
          event_caption_key = event_name
          if options.include?(:custom_caption_mapper) 
            mapper = options[:custom_caption_mapper]
            event_caption_key = mapper[event_name] if mapper.include?(event_name)
          end
          localized_event_name = ::I18n.t("activemodel.state_events.#{class_name}.#{event_caption_key}",
                                          :default => [ 
                                            ::I18n.t("activemodel.state_events.#{event_caption_key}")
                                          ])
          memo += template.content_tag(:button, localized_event_name, { 
            :type => :button, 
            'data-event_name' => event_name,
            'data-root' => root_controller, 
            'data-event_header' => 
              ::I18n.t("activemodel.state_events.#{class_name}.headers.#{event_caption_key}", 
                :default => [ ::I18n.t("activemodel.state_events.#{parent_class_name}.headers.#{event_caption_key}", :default => localized_event_name) ]),
            'data-event_description' => 
              ::I18n.t("activemodel.state_events.#{class_name}.descriptions.#{event_caption_key}", 
                :default => [ ::I18n.t("activemodel.state_events.#{parent_class_name}.descriptions.#{event_caption_key}", :default => localized_event_name) ]),
            'data-root_id' => root.id,
            'data-entity_id' => object.id,
            :class => css_class
          }) 
        else
          memo += ""
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
      content = template.content_tag(:label, ::I18n.t("activemodel.state_events_label"), :for => :state_events_select ) <<
      template.content_tag(:select, template.raw(option_list), :class => :state_events_select, :id => :state_events_select) <<
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
      content = template.content_tag(:label, ::I18n.t("activemodel.state_events_label"), :for => :state_events_select ) <<
      template.content_tag(:select, option_list, :class => :state_events_select, :id => :state_events_select ) <<
      template.tag(:input, { :type => :hidden, :name => :state_event, :id => :state_event_field })
      template.content_tag :li, content
    end
  end
end
