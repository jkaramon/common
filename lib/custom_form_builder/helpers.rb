module CustomFormBuilder
  # Form builder misc control helpers
  module Helpers
    
    private 

    
    # Adds or overwrite [:input_html][:disabled] = "disabled" in options hash
    # @param [Hash] options 
    def add_disabled_option(options)
      options[:input_html] ||= {}
      options[:input_html][:disabled] = "disabled"
      options
    end
    
  end
end