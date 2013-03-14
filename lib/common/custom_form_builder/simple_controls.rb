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
      start_time = Time.now
      return "" if control_hidden?(method)
      wrap = !options.include?(:wrapper) || options[:wrapper]
      wrapper_tag = :li
      wrapper_tag = options[:wrapper] if options.include?(:wrapper)

      summary_options(options)

      options[:as]     ||= default_input_type(method, options)

      annotations = annotation_options(method, options)
      options[:input_html].merge!(annotations) if options[:input_html]
      html_class = [ options[:as], (options[:required] ? :required : :optional) ]
      html_class << 'error' if @object && @object.respond_to?(:errors) && !@object.errors[method.to_sym].blank?

      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:id]  ||= generate_html_id(method)
      wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')

      if options[:input_html] && options[:input_html][:id]
        options[:label_html] ||= {}
        options[:label_html][:for] ||= options[:input_html][:id]
      end

      input_parts = self.class.inline_order.dup
      input_parts = input_parts - [:errors, :hints] if options[:as] == :hidden

      list_item_content = input_parts.map do |type|
        send(:"inline_#{type}_for", method, options)
      end.compact.join("\n")
      
      content = Formtastic::Util.html_safe(list_item_content)
      end_trace  "Rendering input :#{method} ", start_time 
      if wrap 
        return template.content_tag( wrapper_tag, content, wrapper_html)
      else
        return content
      end

    end

    def phone_input(method, options = {})
      return "" if control_hidden?(method)
      summary_options(options)
       
      summary = options[:input_html][:class]
      summary_length = options[:input_html]["data-summary_length"]
      options.merge!(annotation_options(method, options))
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
      options[:html] ||= {}
      options[:html][:novalidate] = :novalidate
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
      options[:wrapper_html] ||= {}
      options[:wrapper_html][:class] = "#{options[:wrapper_html][:class]} #{method}"  
      options[:input_html][:class] = "#{options[:input_html][:class]} #{method}"
      options[:input_html][:class] += ' resizeable' if resizeable
      case get_rule(method).visibility
      when :enabled 
        return super(method, options) 
      when :disabled 
        options[:input_html][:value] = template.fulltext_format(object.send(method))
        options[:input_html][:class] += " markdown"
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
      options[:date_format] ||= "%F"
      case get_rule(method).visibility
      when :enabled 
        return date_enabled(method, options)
      when :disabled
        options[:input_html] ||= {}
        val = object.send(method)
        val = val.strftime(options[:date_format]) if val.present?
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
      options.merge!(annotation_options(method, options))

      lbl = self.label(method, options_for_label(options)) 
      date_field =  self.text_field(method, options)
      time_field = self.text_field(method, time_field_options).gsub(/#{method}/, "#{method}_time").html_safe
        lbl + date_field + time_field 
    end

    def date_enabled(method, options)
      object_name = object.class.to_s.underscore.to_sym
      value = ActionView::Helpers::InstanceTag.value(object, method)
      date_value = value.nil? ? "" : value.to_s(:short)
      summary_options(options)
      options.merge!(annotation_options(method, options))

      options[:input_html] ||= {}
      options[:class] ||= 'date_picker ' + options[:input_html][:class]
      options[:value] ||= date_value
      self.label(method, options_for_label(options)) + self.text_field(method, options)
    end

    def time_enabled(method, options)
      object_name = object.class.to_s.underscore.to_sym
      value = ActionView::Helpers::InstanceTag.value(object, method)
      time_value = value.nil? ? "" : value.to_s(:time)
      options[:input_html] ||= {}
      time_field_options = options.merge(:value => time_value, :class => 'time_picker')
      self.label(method, options_for_label(options)) + self.text_field(method, time_field_options)
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
      input_options.merge!(annotation_options(method, options))

      lbl = self.label(method, options_for_label(options))
      puts lbl
      chk = self.check_box method, input_options
      if options[:label_position]==:right
        "#{chk} #{lbl}"
      else
        "#{lbl} #{chk}"
      end
    end

    def simple_checkbox_input(method, options)
      input_options =  options.delete(:input_html) || {}
      input_options.merge!(annotation_options(method, options))
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
      options.merge!(annotation_options(method, options))
      options[:input_html] ||= {}

      value = ActionView::Helpers::InstanceTag.value(object, "#{method}_hours")
      label = self.label(method,options_for_label(options.merge({:class=> "time_hours"})))
      label << self.text_field("#{method}_hours", options[:input_html].merge({:value=>value, :class => "time_hours"})) <<
      template.content_tag(:span, template.t('hours') , options)
      if minutes
        value = ActionView::Helpers::InstanceTag.value(object, "#{method}_minutes")
        label << self.text_field("#{method}_minutes", options[:input_html].merge({:value=>value, :class => "time_minutes"})) <<
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

