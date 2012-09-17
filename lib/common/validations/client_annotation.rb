require "cgi"

module Validations
  class ClientAnnotation
    attr_accessor :object
    def initialize(object)
      @object = object
    end

    # returns array of validation items.
    # Each validation item is a hash with the following structure:
    # {
    #   :attr              => :name,            # attribute name
    #   :attr_display_name => 'Name',           # localized attribute name
    #   :kind              => :presence,        # Validator kind (same as the ActiveModel convention)
    #   :error             => "can't be blank"  # Localized error message for given validator
    # }
    # Additional options specific to the given validator may be included in a hash
    def validations_on(attribute, filter_options = {})
      klass = @object.class
      filter_kind = filter_options[:kind]
      validators = klass.validators_on(attribute).map do |validator|
        items = []
        kind = validator.kind
        next if filter_kind.present? && filter_kind != kind
        items << validator.attributes.map do |attr|
          attr_display_name = ''
          error = ''
          translation_mode = ::I18n.respond_to?(:"translation_mode?") && ::I18n.translation_mode?
          if translation_mode
            attr_display_name = klass.human_attribute_name(attr, :mode => :normal)
          else
            attr_display_name = klass.human_attribute_name(attr)
          end
          error = object.errors.generate_message(attribute, error_by_kind(kind), validator.options.dup)

          validator.options.dup.merge({
            :attr               => attr,
            :attr_display_name  => escape(attr_display_name),
            :kind               => kind,
            :error              => escape(error)          
          })

        end
        items
      end
      result = validators.flatten.compact
      result = [] if result.nil?
      result.delete_if {|v| v[:attr] != attribute }
    end


    # True, if given attribute is required
    def required?(attribute)
      validations_on(attribute).any? { |validator| validator[:kind] == :presence }
    end

    # If provided, return hint commonly used as a placeholder in form input, otherwise returns nil
    # Translations are searched in activemodel.hints.{model_class}.{attribute}
    def hint(attribute)
      hint_name(attribute)
    end



    private

    def hint_name(attribute)
      defaults = @object.class.lookup_ancestors.map do |klass|
        :"activemodel.hints.#{klass.model_name.i18n_key}.#{attribute}"
      end

      defaults << :"hints.#{attribute}"
        defaults << ''      

      options = { :default => defaults }
      result = I18n.translate(defaults.shift, options)
      result.blank? ? nil : result
    end




    def escape(val)
      return nil if val.nil?
      val.gsub('"', "&quot;")
    end

    def error_by_kind(kind)
      error_message_mapper.fetch(kind, kind)
    end

    def error_message_mapper
      {
        :presence => :blank
      }
    end




  end
end
