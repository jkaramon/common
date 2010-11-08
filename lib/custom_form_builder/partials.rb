module CustomFormBuilder
  # Partial render helpers
  module Partials
    # Calls @see ApplicationHelper#nested_partial
    def nested_partial(name, locals_options = {})
      locals_options[:form] ||= self
      template.nested_partial(name, locals_options)
    end
    
    
    # Calls @see ApplicationHelper#partial
    def partial(name, locals_options = {})
      locals_options[:form] ||= self
      template.partial(name, locals_options)
    end
  end
end