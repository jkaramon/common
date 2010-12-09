module ActionController
  
  # Needed for Formtastic
  module RecordIdentifier
    # Returns the plural class name of a record or class. Examples:
    #
    #   plural_class_name(post)             # => "posts"
    #   plural_class_name(Highrise::Person) # => "highrise_people"
    def plural_class_name(record_or_class)
      model_name_from_record_or_class(record_or_class).plural
    end

    # Returns the singular class name of a record or class. Examples:
    #
    #   singular_class_name(post)             # => "post"
    #   singular_class_name(Highrise::Person) # => "highrise_person"
    def singular_class_name(record_or_class)
      model_name_from_record_or_class(record_or_class).singular
    end

    private
    def model_name_from_record_or_class(record_or_class)
      (record_or_class.is_a?(Class) ? record_or_class : record_or_class.class).model_name
    end
  end


end

