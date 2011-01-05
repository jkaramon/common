module CustomFormBuilder
  ##
  # All select (dropdown) controls goes here. 
  module SelectControls
    
    #defines basic select input
    # @param [Symbol, String] method - method name of current object
    # @param [Hash] options 
    # @option options :label_method (:name)  
    # @option options :value_method (:id) 
    # @option options :collection (nil)
    # @option options [Class] :model (nil) - type of the collection items
    # @option options :selected (nil) - selected value
    # @option options :include_blank (true) - True if blank item is rendered to allow select nothing.
    def select_input(method, options)
      options[:label_method] ||= :name
      options[:value_method] ||= :id 
      select_default(method, options)
      options[:collection] ||= []
      case get_rule(method).visibility
        when :enabled 
          return super(method, options) 
        when :disabled
          return disabled_field(method, options)
      end
    end

    def currency_input(method, options)
      input_name = generate_association_input_name(method)
      values = "<option value=''></option>"
      currency = Money::Currency::TABLE
      currency.each { |key, value|
        values += "<option value='#{value[:iso_code]}'"
        values += " selected='selected'" if options[:selected] == value[:iso_code]
        values += " >#{value[:iso_code]}</option>"
      }
      self.label(method,options_for_label(options)) <<
      template.select_tag("#{@object_name}[#{input_name}]", template.raw(values))
    end

    def approval_resolution_input(method, options)
      input_name = generate_association_input_name(method)
      values = ""
      resolution = ApprovalResolution.all
      resolution.each { |value|
        values += "<option value='#{value.id}'"
        values += " selected='selected'" if options[:selected] == value.id
        values += " >#{value.name}</option>"
      }
      case get_rule(method).visibility
        when :enabled
          self.label(method,options_for_label(options)) <<
          template.select_tag("#{@object_name}[#{input_name}]", template.raw(values))
        when :disabled
          self.label(method,options_for_label(options)) <<
          template.text_field_tag(method, I18n.translate("activemodel.attributes.approval_resolution.#{options[:selected]}"), {:class => 'disabled'})
      end
    end

    # Defines ticket_source select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see TicketSource
    def ticket_source_input(method, options)
      select_default(method, options)
      selected = TicketSource.all(:id => options[:selected]).first 
      options[:collection] ||= TicketSource.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      options[:model] ||= TicketSource
      options[:include_blank] ||= false
      select_input(method, options)
    end
    
    # Defines configuration_item_status select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ConfigurationItemStatus
    def configuration_item_status_input(method, options)
      options[:collection] ||= ConfigurationItemStatus.all
      options[:model] ||= ConfigurationItemStatus 
      options[:include_blank] ||= false
      select_input(method, options)
    end
    
    # Defines operator_group_input select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ResolutionGroup
    def operator_group_input(method, options)
      options[:collection] ||= @object.operator_groups
      options[:model] ||= ResolutionGroup
      selected = nil
      if @object.operator_group
        selected = @object.operator_group.id
      elsif @object.default_operator_group
        selected = @object.default_operator_group.id 
      end
      options[:include_blank] ||= false
      select_input(method, options)
    end
    
    # Defines contact_type select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ContactType
    def contact_type_input(method, options)
      options[:model] ||= ContactType
      select_default(method, options)
      selected = ContactType.all(:id => options[:selected]).first
      options[:collection] ||= ContactType.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end

    # Defines message_type select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ContactType
    def message_type_input(method, options)
      options[:model] ||= MessageType
      options[:collection] ||= MessageType.all
      select_input(method, options)
    end
    
    # Defines urgency select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Urgency
    def urgency_input(method, options)
      options[:model] ||= Urgency
      select_default(method, options)
      selected = Urgency.all(:id => options[:selected]).first
      options[:collection] ||= Urgency.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end
    
    # Defines sla select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Sla
    def sla_input(method, options)
      options[:model] ||= Sla
      select_default(method, options)
      selected = Sla.all(:id => options[:selected]).first
      options[:collection] ||= Sla.actives_or_self(selected)
      select_input(method, options)
    end

    # Defines impact select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Impact
    def impact_input(method, options)
      options[:model] ||= Impact
      select_default(method, options)
      selected = Impact.all(:id => options[:selected]).first
      options[:collection] ||= Impact.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end
    
    # Defines service select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Service
    def service_input(method, options)
      options[:model] ||= Service
      select_default(method, options)
      selected = Service.all(:id => options[:selected]).first
      options[:collection] ||= Service.actives_or_self(selected)
      select_input(method, options)
    end
    
    # Defines resolution_code select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ResolutionCode
    def resolution_code_input(method, options)
      options[:model] ||= ResolutionCode
      options[:collection] ||= ResolutionCode.all
      select_input(method, options)
    end

    def problem_resolution_code_input(method, options)
      options[:model] ||= ProblemResolutionCode
      select_default(method, options)
      selected = ProblemResolutionCode.all(:id => options[:selected]).first
      options[:collection] ||= ProblemResolutionCode.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end

    def incident_resolution_code_input(method, options)
      options[:model] ||= IncidentResolutionCode
      select_default(method, options)
      selected = IncidentResolutionCode.all(:id => options[:selected]).first
      options[:collection] ||= IncidentResolutionCode.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end
    # Defines request_resolution_code select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see RequestResolutionCode
    def request_resolution_code_input(method, options)
      options[:model] ||= RequestResolutionCode
      select_default(method, options)
      selected = RequestResolutionCode.all(:id => options[:selected]).first
      options[:collection] ||= RequestResolutionCode.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end
    
    # Defines sla_breaching_code select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see SlaBreachingCode
    def sla_breaching_code_input(method, options)
      options[:model] ||= SlaBreachingCode
      select_default(method, options)
      selected = SlaBreachingCode.all(:id => options[:selected]).first
      options[:collection] ||= SlaBreachingCode.actives_or_self(selected).sort_by{ |ts| ts.sequence_id }
      select_input(method, options)
    end
    
    # Defines resolution_group select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ResolutionGroup
    def resolution_group_input(method, options)
      options[:model] ||= ResolutionGroup
      options[:collection] ||= ResolutionGroup.all
      options[:label_method] ||= :display_name
      select_input(method, options)
    end
    
    # Defines time_zone select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see ActiveSupport::TimeZone
    def time_zone_input(method, options)
      options[:collection] ||= ActiveSupport::TimeZone.all
      options[:label_method] ||= :to_s
      options[:value_method] ||= :name
      select_input(method, options)
    end
    
    # Defines calendar select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Calendar
    def calendar_input(method, options)
      options[:model] ||= Calendar
      select_default(method, options)
      selected = Calendar.all(:id => options[:selected]).first
      options[:collection] ||= Calendar.actives_or_self(selected)
      select_input(method, options)
    end

    # Defines Language select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Language
    def language_input(method, options)
      options[:model] ||= Language
      options[:collection] ||= Language.all
      options[:value_method] ||= :code
      select_input(method, options)
    end

    # Defines Network connection type select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see NetworkConnectionType
    def network_connection_type_input(method, options)
      options[:model] ||= NetworkConnectionType
      options[:collection] ||= NetworkConnectionType.all
      options[:value_method] ||= :code
      select_input(method, options)
    end

    # Defines CSV Import type select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Import::CsvImportType
    def csv_import_type_input(method, options)
      options[:model] ||= Import::CsvImportType
      options[:collection] ||= Import::CsvImportType.all
      options[:value_method] ||= :code
      select_input(method, options)
    end

    # Defines Worklog type select input
    # See CustomFormBuilder::SelectControls#select_input select_input for available options 
    # and source code for the defaults.
    # The @object variable must be set to a ticket instance
    # @see CustomFormBuilder::SelectControls#select_input 
    # @see Import::WorklogType
    def worklog_type_input(method, options)
      input_name = generate_association_input_name(method)
      default_text = template.t('activemodel.attributes.worklog_type.select_caption')
      values = "<option value=''>#{default_text}</option>"
      w = WorklogType.all(:ticket_type=>@object.class.to_s)
      w.each { |item|
        values += "<option value='#{item.id}'>#{item.name}</option>"
      }
      template.select_tag("#{@object_name}[#{input_name}]", template.raw(values), options)
    end

    def priority_select_input(method, options)
      values = ""
      num = 1
      while num <= Priority.priorities
        values += "<option value='#{num}' >#{num}</option>" if num != options[:current]
        num += 1
      end      
      self.label(method,options_for_label(options)) <<
      template.select_tag("priority_select", template.raw(values))
    end

    def priority_select_change_input(method, options)
      options[:class] ||= ""
      options[:class] += " summary " if options.include?(:summary)
      if(options.include?(:summary_length))
        options["data-summary_length"] = options[:summary_length]
      else
        options["data-summary_length"] = "20"
      end
      case get_rule(method).visibility
        when :enabled
          values = ""
          num = 1
          while num <= Priority.priorities
            if num != options[:current]
              values += "<option value='#{num}' >#{num}</option>"
            else
              values += "<option value='#{num}' selected='selected' class='current' >#{num}</option>"
            end
            num += 1
          end
          self.label(method,options_for_label(options)) <<
          template.select_tag("priority_change_select", template.raw(values), options)
        when :disabled
          return disabled_field(method, options)
      end
    end


    def kb_area_input(method, options)
      input_name = generate_association_input_name(method)
      selected_p = ""
      selected_i = ""
      if options[:selected] == "#{template.t('activemodel.attributes.kb.internal')}"
        selected_i = "selected='selected'"
      end
      if options[:selected] == "#{template.t('activemodel.attributes.kb.public')}"
        selected_p = "selected='selected'"
      end
      values = "<option #{selected_p} value='#{template.t('activemodel.attributes.kb.public')}'>#{template.t('activemodel.attributes.kb.public')}</option>"
      values += "<option #{selected_i} value='#{template.t('activemodel.attributes.kb.internal')}'>#{template.t('activemodel.attributes.kb.internal')}</option>"

      self.label(method, options_for_label(options)) <<
      template.select_tag("#{@object_name}[#{input_name}]",template.raw(values))
    end


    def period_select_input(method, options)
      options[:label_method] ||= :name
      options[:value_method] ||= :id
      select_default(method, options)
      options[:collection] ||= []
      case get_rule(method).visibility
        when :enabled
          return select_input(method, options)
        when :disabled
          return period_disabled_field(method, options)
      end
    end

    def period_disabled_field(method, options)
      self.label(method, options_for_label(options)) << period_disabled_content(method, options)
    end

    def period_disabled_content(method, options)
      options[:input_html] ||= {}
      options[:input_html][:class] ||= ""
      options[:input_html][:class] += " #{options[:class]} #{method} disabled"
      value = ""
      if options[:input_html][:value].present?
        value = options[:input_html][:value]
      else
        value = object.send(method).id unless object.send(method).nil?

        if value.to_s != ""
          value = template.t("activemodel.attributes.periods.#{value.to_s}")
        end
      end
      options[:input_html][:value]=""
      template.content_tag :span, value, options[:input_html]
    end

    def boolean_select_input(method, options)
      input_name = generate_association_input_name(method)
      selected = object.send(method)
      values = ""
      bools = { -1 => ::I18n.t(:bool_unknown), 1 => ::I18n.t(:bool_yes), 0 => ::I18n.t(:bool_no) }
      bools.each { |key, value|
        values += "<option value='#{key}'"
        values += " selected='selected'" if selected == key
        values += " >#{value}</option>"
      }
      self.label(method,options_for_label(options)) <<
      template.select_tag("#{@object_name}[#{input_name}]", template.raw(values))
    end
   
    def ticket_status_select_input(method, options)
      input_name = generate_association_input_name(method)
      selected = object.send(method)
      klass = Class.const_get( options[:class] )
      values = "<option value=''>#{::I18n.t(:all)}</option>"
      klass.state_machine.states.each do |s|
        values += "<option value='#{s.name}'"
        values += " selected='selected'" if selected == s.name
        values += " >#{::I18n.t(s.name)}</option>"
      end
      self.label(method,options_for_label(options)) <<
      template.select_tag("#{@object_name}[#{input_name}]", template.raw(values))
    end
 
    private 
    
    def select_default(method, options)
      options[:label_method] ||= :name
      options[:value_method] ||= :id
      return if options.include?(:selected)
      value_method = options[:value_method]
      if @object.respond_to?(method)
        value = @object.send(method)
        options[:selected] = value
      end
      method_wo_id = method.to_s.sub(/_id$/, '').to_sym
      if @object.respond_to?(method_wo_id)         
        options[:selected] = @object.send(method_wo_id).try(value_method)
      end 
    end
    
  end
end