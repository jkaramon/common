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
