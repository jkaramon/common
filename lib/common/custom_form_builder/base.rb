require 'formtastic'

require_relative 'annotations'
require_relative 'helpers'
require_relative 'container_controls'
require_relative 'nested_forms'
require_relative 'partials'
require_relative 'select_controls'
require_relative 'simple_controls'
require_relative 'state_controls'
require_relative 'suggest_controls'
require_relative 'tab_panels'

module CustomFormBuilder
  # Form builder which extends 
  # @see http://rdoc.info/projects/justinfrench/formtastic" Formtastic::SemanticFormBuilder
  # Builder renders controls according to result of the rule engine evaluation. 
  # Engine evaluates control state (visibility, panel_state) for each control. 
  # Rules are defined separately for each object in config/visibility_rules.
  class Base < ::Formtastic::SemanticFormBuilder 
    include Helpers
    include Annotations
    include ContainerControls
    include SimpleControls
    include SelectControls
    include SuggestControls
    include StateControls
    include Partials
    include NestedForms
    include TabPanels
   
    cattr_accessor :logger


     
    def debug(msg) 
      self.class.logger.debug(msg) if self.class.logger
    end

       
    def end_trace(msg, start_time)
      debug '-------------------------------------------------------'
      debug "#{msg} - #{ '%.3f' % ((Time.now - start_time)*1000) } ms."
      debug '-------------------------------------------------------'
    end
 
    
    # Returns rule object for the given metho name. 
    # @param [Symbol, String] method - method name of current object
    # @return [Rules::Rule] for the method name. If rule engine is not defined, returns enabled rule.
    def get_rule(method)
      return Rules::Rule.enabled if rule_engine.nil?
      control_id = rule_control_id(method).to_sym
      rule_engine.evaluate(control_id)
    end
    
    # @param [Symbol, String] method - method name of current object
    # @return [Boolean] true if visibility rule evaluated to :enabled
    def control_enabled?(method)
      get_rule(method).enabled?
    end
    
    # @param [Symbol, String] method - method name of current object
    # @return [Boolean] true if visibility rule evaluated to :enabled
    def control_disabled?(method)
      get_rule(method).disabled?
    end
    
    # @param [Symbol, String] method - method name of current object
    # @return [Boolean] true if visibility rule evaluated to :enabled
    def control_hidden?(method)
      get_rule(method).hidden?
    end
    
    def summary_options(options)
      options[:input_html] ||= {}
      options[:input_html][:class] ||= ""
      options[:input_html][:class] += " summary " if options.include?(:summary) && options[:summary]
      if(options.include?(:summary_length))
      options[:input_html]["data-summary_length"] = options[:summary_length] else
      options[:input_html]["data-summary_length"] = "20"
      end
      options
    end

    def field_set_title_from_args(*args) #:nodoc:
      options = args.extract_options!
      options[:name] = options.delete(:title) if options[:title].present?
      title = options[:name]

      if title.blank?
        valid_name_classes = [::String, ::Symbol]
        valid_name_classes.delete(::Symbol) if !block_given? && (args.first.is_a?(::Symbol) && self.content_columns.include?(args.first))
        title = args.shift if valid_name_classes.any? { |valid_name_class| args.first.is_a?(valid_name_class) }
      end
      title = localized_string(title, title, :title) if title.is_a?(::Symbol)
      title
    end
   
    private 
    
    # @param [Symbol, String] method - method name of current object
    # @return  [String] control_id as defined in rule file
    def rule_control_id(method)
      generate_html_id(method, "").gsub(/_$/, "")
    end
    
    # @param [Symbol, String] method - method name of current object
    # @return [Rules::Engine] rule engine instance
    def rule_engine
      @rule_engine ||= template.controller.rule_engine if template.controller.respond_to?(:rule_engine)
    end
    
    
    
    
    
    
    
  
  end 
end
