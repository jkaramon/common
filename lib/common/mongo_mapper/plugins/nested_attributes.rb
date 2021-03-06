module MongoMapper
  module Plugins
    module NestedAttributes
      extend ActiveSupport::Concern

      module ClassMethods

        def accepts_nested_attributes_for(*attr_names)
          options = { :allow_destroy => false }
          options.update(attr_names.extract_options!)
          options.assert_valid_keys(:allow_destroy, :reject_if)
          for association_name in attr_names

            if (association = associations.select { |key, value| key == association_name }) && association.present?
              association = association[association_name]
              type = association.is_a?(MongoMapper::Plugins::Associations::ManyAssociation) ? :many : :one
              custom_class ||= association.class_name.constantize if association.class_name.present?
            elsif (key = keys.select { |key, value| key == association_name.to_s }) && key.present? && key.last.last.embeddable?
              type = 'embedded_key'
              custom_class = key.values.last.type
            else
              raise ArgumentError, "No association found for name `#{association_name}'. Has it been defined yet?\n#{associations.inspect}"
            end
            klass = custom_class || association_name.to_s.classify.constantize

            module_eval %{
            def #{association_name}_attributes=(attributes)
              assign_nested_attributes_for_#{type}_association(:#{association_name}, #{klass}, attributes, #{options[:allow_destroy]})
            end
            }, __FILE__, __LINE__
          end
        end

        protected

        def association_or_embeddable_key_exists?(name)
          return true
          matching_key = keys.select{ |key, value| key == name.to_s }
          matching_key.present? && matching_key.last.last.embeddable?
        end

      end

      module InstanceMethods
        UNASSIGNABLE_KEYS = %w{ id _id _destroy }

        def assign_nested_attributes_for_many_association(association_name, klass, attributes_collection, allow_destroy)
          unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
            raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
          end

          if attributes_collection.is_a? Hash
            attributes_collection = attributes_collection.sort_by { |index, _| index.to_i }.map { |_, attributes| attributes }
          end

          attributes_collection.each do |attributes|
            attributes.stringify_keys!
            entity_id =  attributes['_id'] ||  attributes['id']
            if existing_record = send(association_name).detect { |record| record.id.to_s == entity_id.to_s }

              if has_destroy_flag?(attributes) && allow_destroy
                if klass.embeddable?
                  send(association_name).delete(existing_record)
                else
                  existing_record.destroy
                end
              else
                existing_record.attributes = attributes.except(*UNASSIGNABLE_KEYS)
              end
            else
              attributes['id'] = nil
              attributes['_id'] = nil
              send(association_name) << klass.new(attributes)
            end

          end

        end

       def assign_nested_attributes_for_one_association(association_name, klass, attributes, allow_destroy)
          unless attributes.is_a?(Hash)
            raise ArgumentError, "Hash expected, got #{attributes.class.name} (#{attributes.inspect})"
          end

          attributes.stringify_keys!

          if attributes['_id'].blank?
            send("#{association_name}=", klass.new(attributes))
          else 
            existing_record = send(association_name)
            if existing_record.has_destroy_flag?(attributes) && allow_destroy
              if klass.embeddable?
                send("#{association_name}=", nil)
              else
                existing_record.destroy
              end
            else
              existing_record.attributes = attributes.except(*UNASSIGNABLE_KEYS)
            end
          end
        end

        alias_method :assign_nested_attributes_for_embedded_key_association, :assign_nested_attributes_for_one_association

        def has_destroy_flag?(hash)
          Boolean.to_mongo(hash['_delete'])
        end

      end
    end

  end
end
