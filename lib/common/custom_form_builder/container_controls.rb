module CustomFormBuilder
  ##
  # Container controls are defined here. Container controls is a control which takes block as its last parameter. It effectively wraps content defined in block.
  # It can be then used in view as follows:
  #   <% form.content_panel :name=>:subject do  %>
  #     .
  #     .
  #   <% end %>
  module ContainerControls
    
    # Renders top level collapsible fieldset.
    # @param [Hash] options
    # @option options [String, Symbol] :name - section header. 
    # If Symbol is provided then it is used as localization key in scope formtastic.titles 
    # @param block - block to wrap
    def collapsible_fieldset(options = {}, &block)
      method = "section_#{options[:name]}"
                   
      rule = get_rule(method)
      return if rule.visibility==:hidden 
      
      title = field_set_title_from_args(options)
      state = rule.panel_state
      state = :collapsed if options[:collapsed]

      options[:class] = "inputs #{options[:name].to_s.underscore} collapsible #{state} content_panel #{options[:class]}"
      state_icon = options[:collapsed]==true ? 'ui-icon-triangle-1-n' : 'ui-icon-triangle-1-s';
      state_text = template.content_tag(:div, "", :class => "collapse-state-text")
      icon = template.content_tag(:div, "", :class => "ui-expandable-icon ui-icon #{state_icon}")
      header_options = context_help_attrs(method, options)
      header_options[:class] += " content"
      title = template.content_tag(:div, title, header_options)
      excerpt = template.content_tag("span","", :class=>"excerpt")
      options[:name] = icon + state_text + title + excerpt
      field_set_and_list_wrapping_div_legend(options, &block)
    end

  
    def context_help_attrs(method, options)
      show_help = options[:context_help] != false
      header_options = {}
      help_doc = nil
      if show_help
        help_type_name = object.class.to_s.demodulize.underscore
        help_type_name = "ticket" if object.is_a?(Tickets::TicketBase)
        header_options['data-help_doc'] = "#{help_type_name}_#{method}"
        header_options[:class] ||= ""
        header_options[:class] += " help_source"
      end
      header_options  
    end

    
    
    
    
    # Renders top level non-collapsible fieldset.
    # @param [Hash] options
    # @option options [String, Symbol] :name - section header. 
    # If Symbol is provided then it is used as localization key in scope formtastic.titles 
    # @param block - block to wrap
    def content_panel(options = {}, &block)
      method = "section_#{options[:name]}"
      return if control_hidden?(method) 
      
      title = field_set_title_from_args(options)
      options[:class] = "inputs #{options[:name]} content_panel"
      header_options = context_help_attrs(method, options)
      header_options[:class] += " content"
      options[:name] = template.content_tag(:div, title, header_options)
      if block_given?
        field_set_and_list_wrapping_div_legend(options, &block)
      end
    end
    
    # @see Formtastic::SemanticFormBuilder#inputs
    def inputs(*args, &block) 
      options = args.last.is_a?(::Hash) ? args.last : {}
      return super(*args, &block) unless options.include?(:name)
      method = "section_#{options[:name]}"
      return super(options, &block) if control_enabled?(method) 
      return super(add_disabled_option(options), &block) if control_disabled?(method) 
    end
    
    
    
    private 
    
    # Template file 
    def tpl_file
      template.template
    end
    
    # replace legend with div
    def field_set_and_list_wrapping_div_legend(*args, &block) #:nodoc:
      contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
      html_options = args.extract_options!
      wrapper_tag = :ol
      wrapper_tag = html_options[:wrapper] if html_options.include?(:wrapper)
      legend  = html_options.delete(:name).to_s
      legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
      legend  = template.content_tag(:div, template.content_tag(:span, legend), :class=>'legend') unless legend.blank?

      if block_given?
        contents = if template.respond_to?(:is_haml?) && template.is_haml?
          template.capture_haml(&block)
        else
          template.capture(&block)
        end
      end

      # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
      contents = contents.join if contents.respond_to?(:join)
      fieldset = template.content_tag(:fieldset,
        legend << template.content_tag(wrapper_tag, contents),
        html_options.except(:builder, :parent)
      )
      fieldset
    end
  end
end
