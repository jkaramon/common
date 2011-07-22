module MongoMapper
  module Plugins
    module Localization
      extend ActiveSupport::Concern

      module ClassMethods
        def self_and_descendants#nodoc:
          klass = self
          classes = []
          while klass != Object  
            classes << klass 
            klass = klass.superclass
          end
          classes
        rescue
          [self]
        end

        # Transforms attribute key names into a more humane format, such as "First name" instead of "first_name". Example:
        #   Person.human_attribute_name("first_name") # => "First name"
        # This used to be depricated in favor of humanize, but is now preferred, because it automatically uses the I18n
        # module now.
        # Specify +options+ with additional translating options.
        def human_attribute_name(attribute_key_name, options = {})
          base_attributes = [:created_at, :created_by, :updated_at, :active, :id, :name]
          attribute_key_name = attribute_key_name.to_s.gsub(/\?$/, '').to_sym
          defaults = self_and_descendants.map do |klass|
            "#{klass.name.underscore.gsub('/', '.')}.#{attribute_key_name}".to_sym
          end
          defaults << options[:default] if options[:default]
          defaults << attribute_key_name if base_attributes.include?(attribute_key_name)
          defaults.flatten!
          result = ::I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activemodel, :attributes]))
          if result.include?("translation missing")
            default_result = ::I18n.translate(attribute_key_name.to_sym, :scope => [:activemodel, :attributes]) 
            result = default_result unless (default_result.include?("translation missing") or default_result.is_a?(Hash))
          end
          raise "Locatization of the '#{defaults.inspect}' results in a hash '#{result.inspect}'. Use leaf localization keys only to return single string value." if result.is_a?(Hash)
          result
        end

        # Transform the modelname into a more humane format, using I18n.
        # Defaults to the basic humanize method.
        # Default scope of the translation is active_model.models
        # Specify +options+ with additional translating options.
        def human(options = {})
          defaults = self_and_descendants.map do |klass|
            "#{klass.name.underscore.gsub('/', '.')}".to_sym
          end 
          ::I18n.translate(defaults.shift, {:scope => [:activemodel, :models], :count => 1, :default => defaults}.merge(options))
        end

        alias_method :human_name, :human

      end

    end
  end
end
