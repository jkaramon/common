module CustomFormBuilder
  ##
  # All simple input controls goes here. 
  module SimpleControls
   
    # read only field rendered as label + span
    def readonly(method, options = {})
      
      return "" unless object.respond_to?(method)
      value = object.send(method)
      return "" if (value.blank?)
      options[:label] = true unless options.include?(:label)
      options[:class] ||= 'disabled'
      summary_options(options)
      span_options = {}
      span_options[:class] = options[:class]
      span_options[:class] += " " + options[:input_html][:class]
      span_options["data-summary_length"] = options[:input_html]["data-summary_length"] if options[:input_html].include?("data-summary_length")
      label = ""
      label = self.label(method, options_for_label(options)) if options[:label]
      template.content_tag(:li, template.raw(label << template.content_tag(:span,  template.simple_format(value.to_s), span_options )) )
    end

    def state_input(method, options = {})
      return "" if control_hidden?(method)
      options[:class] ||= ''
      options[:class] += options[:input_html][:class]
      summary_options(options)
      case get_rule(method).visibility
        when :enabled
          return self.label(method,options_for_label(options)) << self.text_field(:state_display_name, options)
        when :disabled
          return self.label(method, options_for_label(options)) << disabled_content(:state_display_name, options)
      end
    end
    
    def input(method, options = {})
      return "" if control_hidden?(method)
      summary_options(options)
      # Silence Formtastic :selected deprecation warning 
      ActiveSupport::Deprecation.silence do
        super(method, options)
      end
    end

    def location_name_input(method,options = {})
      summary_options(options)      
      self.label(method,options_for_label(options)) <<
      self.text_field(method,options.merge(:class=>"location_name"))
    end

    def phone_input(method, options = {})
      return "" if control_hidden?(method)
      summary_options(options)
      summary = options[:input_html][:class]
      summary_length = options[:input_html]["data-summary_length"]
      options[:input_html] = {}
      if control_disabled?(method)
        disabled_field(method, options)
      else
        self.label(method, options_for_label(options)) << self.text_field(method, options.merge(:class=>summary,"data-summary_length"=>summary_length))
      end <<
      template.tag("img",{:src=>"/images/skype_call.png", :alt=>"skype", :class=>"skype_call"})
    end
    
    def back_button(options = {})
      options = {
        :type=> :button, 
        :class=>:back_button,
        :value=> ::I18n.t(:back)
      }.merge(options) 
      button(options)
    end

    def alternative_back_button(is_new, options = {})
      if (is_new)
        options = {
          :type=> :button,
          :class=>:alter_back_button,
          :value=> ::I18n.t(:back)
        }.merge(options)
        button(options)
      else
        back_button(options)
      end
    end

    def save_button(options = {})
      options = {
        :type=> :button, 
        :class=>:state_buttonizer, 
        :value=> ::I18n.t(:save) 
      }.merge(options) 
      button(options)
    end
    
    def action_button(options = {})
      options['data-action'] = options[:name]
      options[:value] ||= ::I18n.t("activemodel.state_events.#{options[:name]}")
      options[:class] = "action"
      button(options)
    end
 
    def button(options = {})
      options[:type] ||= :button
      options[:name] ||= :save
      options[:class] = "#{options[:class]} button #{options[:name]}"
      options[:value] ||= ::I18n.t(options[:name]) 
      control_id = "#{options[:name]}_button".to_sym
      options.delete(:name)
      if control_enabled?(control_id)
        return template.tag(:input, options) 
      else
        return ""
      end
    end

    def mark_workaround_buttons(problem, workaround, options = {})
      options['data-root'] = "problems"
      options['data-root_id'] = problem.try(:id)
      options['data-entity_id'] = workaround.try(:id)
      accept = workaround_button('accept', 'do_accept', options)
      reject = workaround_button('reject', 'do_reject', options)

      result = accept+reject if workaround.open?
      result = accept if workaround.rejected?
      result = reject if workaround.accepted?

      case get_rule("mark_workaround_buttons").visibility
      when :enabled
        return result
      when :disabled
        return ""
      end
    end

    def workaround_button(text, action, options)
      options = {
        :type => :button,
        :class => "mark_workaround",
        :value => ::I18n.t(text),
        "data-mark"=> action
      }.merge(options) 
      button(options)
    end
    
    def group_watch_buttons(current_user, options = {})
      result = ""
      return "" if current_user.person.nil?
      current_user.person.manager_resolution_groups.each {|g|
        options['data-gid'] = g.id
        is_watched = WatchItem.group_list_contains_ticket(g, object)
        result = render_watch_buttons(options, is_watched, object.id)
      }
      template.raw(result)
    end
 
    def user_watch_buttons(current_user, options = {})
      is_watched = WatchItem.user_list_contains_ticket(current_user, object)
      template.raw(render_watch_buttons(options, is_watched, object.id))
    end

    def render_watch_buttons(options, is_watched, ticket_id)
      result = ""
      prefix_caption = ""
      prefix_caption = "group_" if options['data-gid']
      options[:class] = "wi_button button"
      options[:show_watch] = true unless options.include?(:show_watch)
      options['style'] = "display: none" if is_watched
      options['data-ticket'] = ticket_id
      options['data-action'] = "watch"
      options['type'] = "button"

      options['title'] = ::I18n.t("#{prefix_caption + options['data-action']}")
      result += template.content_tag(:button, template.image_tag("/images/icons/#{ options['data-action'] }.png") , options) if options[:show_watch]
      if is_watched
        options['style'] = "display: inline-block"
      else
        options['style'] = "display: none"
      end
      options['data-action'] = "unwatch"
      options['title'] = ::I18n.t("#{prefix_caption + options['data-action']}")
      result += template.content_tag(:button, template.image_tag("/images/icons/#{ options['data-action'] }.png"), options)
    end

    # Renders form tag. Used if form should wrap areas outside partial, where form is declared. 
    # Example:
    # <% semantic_fields_for @call do |form| %> 
    #   <%= form.form_tag %>
    # <% end %> 
    # form.form_tag injects form start element (<form ...>) into :begin_form placeholder in the layout file 
    # and form end element (</form>) into :end_form placeholder
    def form_tag( *args)
      options = args.extract_options!
      record_or_name_or_array = self.object
      case record_or_name_or_array
      when String, Symbol
        object_name = record_or_name_or_array
      when Array
        object = record_or_name_or_array.last
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        template.apply_form_for_options!(record_or_name_or_array, options)
        args.unshift object
      else
        object = record_or_name_or_array
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        template.apply_form_for_options!([object], options)
        args.unshift object
      end
      begin_form = template.form_tag(options.delete(:url) || {}, options.delete(:html) || {})
      template.content_for(:begin_form) { begin_form  }
      template.content_for( :end_form) { template.raw('</form>') }
    end

    def string_input(method, options)
      case get_rule(method).visibility
      when :enabled 
        return super(method, options) 
      when :disabled 
        return disabled_field(method, options)
      end
    end 



    def text_input(method, options) 
      resizeable =  options[:resizable] || !options.include?(:resizeable) 
      options[:input_html] ||= {}
      options[:input_html][:class] = 'resizeable' if resizeable
      case get_rule(method).visibility
      when :enabled 
        return super(method, options) 
      when :disabled 
        options[:input_html][:value] = template.simple_format(object.send(method))
        return disabled_field(method, options)
      end
    end
    
    def minutes_input(method, options = {}) 
      options[:input_html] ||= {:class => :minutes }
      case get_rule(method).visibility
      when :enabled 
        return string_input(method, options) 
      when :disabled 
        return disabled_field(method, options)
      end
    end
    def hours_input(method, options = {}) 
      options[:input_html] ||= {:class => :hours }
      case get_rule(method).visibility
      when :enabled 
        return string_input(method, options) 
      when :disabled 
        return disabled_field(method, options)
      end
    end
    
    # Generates time input to write more than 24 hours period
    def absolute_time_input(method, options)
      case get_rule(method).visibility
      when :enabled
        return absolute_time_enabled(method, options)
      when :disabled
        return disabled_field(method, options)
      end
    end

    def absolute_time_enabled(method, options)
      value = ActionView::Helpers::InstanceTag.value(object, method)
      if value.nil?
        time_value = "00:05"
      elsif value.class == String
        time_value = value
      else
        time_value = "#{(value/60).floor}:#{value.modulo(60)}"
      end
      time_field_options = options.merge(:value => time_value, :class => 'absolute_time watermark')
      self.label(method, options_for_label(options)) <<
      self.text_field(method, time_field_options)
    end

    # Generates datetime picker control 
    def datetime_input(method, options)
      options[:date_format] = :short_datetime
      case get_rule(method).visibility
      when :enabled 
        return datetime_enabled(method, options)
      when :disabled 
        return disabled_field(method, options)
      end
    end

    def basic_time_input(method, options)
      options[:date_format] = :time
      case get_rule(method).visibility
      when :enabled 
        return time_enabled(method, options)
      when :disabled 
        return disabled_field(method, options)
      end
    end

    def basic_date_input(method, options)
      options[:date_format] = :short
      case get_rule(method).visibility
      when :enabled 
        return date_enabled(method, options)
      when :disabled
        options[:input_html] ||= {}
        val = object.send(method)
        val = val.to_s(:date_short) if val.present?
        options[:input_html][:value] = val
        return disabled_field(method, options)
      end
    end

    def boolean_text_input(method, options)
      value = object.send(method)
      if (value)
        options[:input_html][:value]= ::I18n.t(:bool_yes)
      else
        options[:input_html][:value]= ::I18n.t(:bool_no)
      end
      case get_rule(method).visibility
      when :enabled
        return input(method, options)
      when :disabled
        return disabled_field(method, options)
      end
    end
    
    def disabled_content(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] ||= "" 
      options[:input_html][:class] += " #{options[:class]} #{method} disabled"
      value = ""
      if options[:input_html][:value].present?
        value = options[:input_html][:value]
      else
        value = object.send(method)
        if options[:model].present? # find label for select input
          inst = options[:model].find(object.send(method)) 
          value = inst.send(options[:label_method]) if inst.present? if options[:label_method].present?
        end
      end
      if value.present? && options[:time_format].present?
        value = value.to_s(options[:time_format])
      end
      options[:input_html][:value]=""
      template.content_tag :span, value, options[:input_html]
    end
    
    def disabled_field(method, options = {})
      self.label(method, options_for_label(options)) << disabled_content(method, options)
    end
     
    # Generates readonly control
    def readonly_input(method, options)
      value = ActionView::Helpers::InstanceTag.value(object, method)
      self.label(method, options_for_label(options)) <<
      template.text_field_tag(method, value.to_s, {:disabled => 'disabled', :class=>'disabled'})
    end
    
 def datetime_enabled(method, options)
      object_name = object.class.to_s.underscore.to_sym
      value = ActionView::Helpers::InstanceTag.value(object, method)
      time_value = value.nil? ? "" : value.to_s(:time)

      date_value = value.nil? ? "" : value.to_s(:short)

      options[:input_html] ||= {}
      time_field_options = options.merge(:value => time_value, :class => 'time_picker')
      options[:class] ||= 'date_picker'
      options[:value] ||= date_value
      options[:class] += " summary " if options.include?(:summary)
      if(options.include?(:summary_length))
        options["data-summary_length"] = options[:summary_length] else
        options["data-summary_length"] = "20"
      end
      self.label(method, options_for_label(options)) <<
      self.text_field(method, options) <<
      self.text_field(method, time_field_options).gsub(/#{method}/, "#{method}_time")
    end

    def date_enabled(method, options)
      object_name = object.class.to_s.underscore.to_sym
      value = ActionView::Helpers::InstanceTag.value(object, method)
      date_value = value.nil? ? "" : value.to_s(:short)
      summary_options(options)
      options[:input_html] ||= {}
      options[:class] ||= 'date_picker ' + options[:input_html][:class]
      options[:value] ||= date_value
      self.label(method, options_for_label(options)) <<
      self.text_field(method, options)
    end

    def time_enabled(method, options)
      object_name = object.class.to_s.underscore.to_sym
      value = ActionView::Helpers::InstanceTag.value(object, method)
      time_value = value.nil? ? "" : value.to_s(:time)
      options[:input_html] ||= {}
      time_field_options = options.merge(:value => time_value, :class => 'time_picker')
      self.label(method, options_for_label(options)) <<
      self.text_field(method, time_field_options)     
    end

    def aligned_checkbox_input(method, options)
      case get_rule(method).visibility
        when :enabled 
          return aligned_checkbox(method, options)
        when :disabled 
          return aligned_checkbox(method, add_disabled_option(options) )
      end
    end
    
    def aligned_checkbox(method, options)
      input_options =  options.delete(:input_html) || {}
      lbl = self.label(method, options_for_label(options)) 
      chk = self.check_box method, input_options
      if options[:label_position]==:right
        "#{chk} #{lbl}"
      else
        "#{lbl} #{chk}"
      end
    end

    def simple_checkbox_input(method, options)
      input_options =  options.delete(:input_html) || {}
      checked_value = options.delete(:checked_value) || '1'
      unchecked_value = options.delete(:unchecked_value) || '0'
      checked = @object && ActionView::Helpers::InstanceTag.check_box_checked?(@object.send(:"#{method}"), checked_value)
                           
      input_options[:id] = input_options[:id] || generate_html_id(method, "")
      chk = template.check_box_tag(
        "#{@object_name}[#{method}]",
        checked_value,
        checked,
        input_options
      )                                                                                                   
      options[:for] ||= input_options[:id]
      lbl = self.label(method, options_for_label(options)) 
                                                                                                                     
      if options[:label_position]==:right
        "#{chk} #{lbl}"
      else
        "#{lbl} #{chk}"
      end
    end

    def priority_input(method, options)
      return "" if control_hidden?(method)
      summary_options(options)
      if control_disabled?(method)
        case get_rule('do_change_priority_button').visibility
          when :enabled
            return disabled_field(method, options) << action_button({:name => :do_change_priority })
          when :disabled
            return disabled_field(method, options)
          when :hide
            return disabled_field(method, options)
        end
      else
        self.label(method,options_for_label(options)) <<
        self.text_field(method,options)
      end
    end
    
    def time_hours_input(method, options)
      return "" if control_hidden?(method)
      summary_options(options)
      case get_rule(method).visibility
        when :enabled
          return enabled_time_hours(method, options)
        when :disabled
          return disabled_time_hours(method, options)
      end
    end

    def enabled_time_hours(method, options)
      minutes = options[:show_minutes]
      options = options.except(:show_minutes)
      value = ActionView::Helpers::InstanceTag.value(object, "#{method}_hours")
      label = self.label(method,options_for_label(options.merge({:class=> "time_hours"})))
      label << template.text_field(@object_name, "#{method}_hours", options.merge({:value=>value})) <<
        template.content_tag(:span, template.t('hours') , options)
      if minutes
        value = ActionView::Helpers::InstanceTag.value(object, "#{method}_minutes")
        label << template.text_field(@object_name, "#{method}_minutes", options.merge({:value=>value})) <<
          template.content_tag(:span, template.t('minutes') , options)
      end
      return label
    end

    def disabled_time_hours(method, options)
      minutes = options[:show_minutes]
      options = options.except(:show_minutes)
      label = self.label(method,options_for_label(options))
      label << disabled_content("#{method}_hours", options) <<
        template.content_tag(:span, template.t('hours') , options)
      if minutes
        label << disabled_content("#{method}_minutes", options) <<
          template.content_tag(:span, template.t('minutes') , options)
      end
    end


  end
end

