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
      
      options[:class] = "inputs #{options[:name]} collapsible #{state} content_panel #{options[:class]}"
      state_icon = options[:collapsed]==true ? 'ui-icon-triangle-1-n' : 'ui-icon-triangle-1-s';
      state_text = template.content_tag(:div, "", :class => "collapse-state-text")
      icon = template.content_tag(:div, "", :class => "ui-expandable-icon ui-icon #{state_icon}")
      title = template.content_tag(:div, title, :class => "content")
      excerpt = template.content_tag("span","", :class=>"excerpt")
      options[:name] = icon + state_text + title + excerpt
      field_set_and_list_wrapping_div_legend(options, &block)
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
      options[:name] = template.content_tag(:div, title, :class => "content")
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
        legend << template.content_tag(:ol, contents),
        html_options.except(:builder, :parent)
      )
      fieldset
    end
  end
end