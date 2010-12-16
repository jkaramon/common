module MongoMapper
  module Plugins

    # Defines Hierarchical entity
    # Included model should respond to #name method
    # Hierarchy info is stored in #parent_id key
    module HierarchicalEntity 

      def self.configure(model)
        raise "Model does not define #name metohd" unless model.respond_to?(:name)
        model.class_eval do
          key :parent_id, ObjectId
          belongs_to :parent, :class_name => model.to_s
        end
      end

      module ClassMethods
        # returns all entities that should be parent of +entity+
        def possible_parents(entity)
          entity.class.all.reject { |c|
            c.id_path.include?(entity.id.to_s) 
          }
        end

        # returns all children of the entity
        def children(entity)
          self.all(:parent_id => entity.id)
        end

        # returns all descendants of the entity
        def hierarchy_descendants(entity)
          ret = []
          arr = entity.children
          return arr if arr.empty?
          ret << arr
          arr.each {|child_item|
            ret << self.hierarchy_descendants(child_item) unless child_item.nil? 
          }
          ret.flatten.compact
        end


      end

      module InstanceMethods
        # returns name of the parent entity
        def parent_name
          parent.name unless parent.nil?
        end
        
        # returns serialized ascendants id string delimited by colon
        # Starts by root entity
        def id_path
          full_path.collect(&:id).join(":")
        end

        # returns serialized ascendants name string delimited by /
        # Starts by root entity
        def full_name
          full_path.collect(&:name).join(" / ")
        end

        alias :display_name :full_name

        # Represent tree branch as array where first element is root category
        def full_path
          return full_path = [self] if parent.nil?
          full_path = parent.full_path << self
        end


        # returns children of the current entity
        def children
          self.class.children(self)  
        end

        # returns descendants of the current entity
        def descendants
          self.class.hierarchy_descendants(self)
        end

        # Processes given block that accepts entity as a parameter for self and each descendant entity
        # Starting from self and finishing by leaf entities 
        def process_self_and_descendants
          yield self
          descendants.each { |item| yield(item) }
        end

        # Processes given block that accepts entity as a parameter for each descendant entity and for self entity
        # Starting from leaf entities and finishing by self 
        def process_descendants_and_self
          descendants.reverse.each { |item| yield(item) }
          yield self
        end


      end

    end
  end
end

