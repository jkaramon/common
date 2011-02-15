module CustomFormBuilder

  module TabPanels

    def tab_panel_vertical(options, &block)
      case get_rule(:tab_panel_vertical).visibility
      when :enabled
        options[:class] += ' tab_panel_vertical '
        return template.content_tag(:div, template.capture(&block), :class=>options[:class])
      when :hidden
        return ""
      end
    end


    def tab_panel(&block)
      case get_rule(:tab_panel).visibility
        when :enabled 
          return template.content_tag(:div, template.capture(&block), :class=> 'tab_panel')
        when :hidden
          return ""
      end
    end
    
    # renders tab content. 
    def tab(options, &block) 
      method = options.delete(:name)
      options[:id] = "tab_#{method}"
      result = case get_rule(method).visibility
        when :enabled 
          inputs(options, &block)
        when :disabled 
          inputs(options, &block)
      end

      template.content_tag :ul, result
    end
    
    def tab_panel_headers(headers, options = {})
      case get_rule(:tab_panel).visibility
        when :enabled 
          return tab_panel_headers_content(headers)
        when :disabled
          return tab_panel_headers_content(headers)
      end
    end
    
    def tab_panel_headers_content(headers)
      result = ""
      headers.each do |header|         #title = header.is_a?(Symbol) ? header : header[1]
        key = header.is_a?(Symbol) ? header : header[0]
        title = header.is_a?(Symbol) ? ::Formtastic::I18n.t(header, :scope => [:titles]) : header[1]

        result << case get_rule(key).visibility
            when :enabled 
              tab_panel_header(key, title)
            when :disabled 
              "<li class='disabled'><a href=\"#tab_#{key}\" tabIndex=\"-1\">#{title}</a></li>"
        end
      end
      template.content_tag :ul, template.raw(result)
    end
    def tab_panel_header(key, title)
      
      link = template.content_tag :a, title, :href => "#tab_#{key}", :tabIndex => -1
      template.content_tag :li, link
    end
  end
end