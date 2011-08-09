# should update search fields (sf_****) with related attributes
# example: changing category attribute on ticket entity should reflect in sf_category attribute

module MongoMapper
  module Plugins
    module SearchFieldItems
      extend ActiveSupport::Concern
      included do
        before_save :update_search_fields

        key :sf_customer, String
        key :sf_person, String
        key :sf_reported_by, String
        key :sf_contact, String
        key :sf_service, String
        key :sf_category, String
        key :sf_resolution_group, String
        key :sf_assigned_name, String

        key :sf_last_update_user, String
        key :sf_last_update_created, String
        key :sf_last_update_description, String

      end

      module ClassMethods

      end

      module InstanceMethods
        # before save callback. Used for data denormalization to enable easier sorting and searching
        def update_search_fields
          self.sf_customer = self.customer.try(:display_name) if self.respond_to?(:customer)
          self.sf_person = self.person.try(:display_name)  if self.respond_to?(:person)
          self.sf_reported_by = self.reported_by.try(:display_name) if self.respond_to?(:reported_by)
          self.sf_contact = self.contact.try(:display_name) if self.respond_to?(:contact)
          self.sf_service = self.service.try(:display_name) if self.respond_to?(:service)
          self.sf_category = self.category.try(:display_name) if self.respond_to?(:category)
          self.sf_resolution_group = self.resolution_group.try(:display_name) if self.respond_to?(:resolution_group)
          self.sf_assigned_name = self.solver.try(:display_name) if self.respond_to?(:solver)
        end

        # after save callback because sources for these attributes are last activities
        def update_activity_search_fields
          doc = {}
          doc[:sf_last_update_user] = self.last_update_user if self.respond_to?(:last_update_user)
          doc[:sf_last_update_created] = self.last_update_created.utc if self.respond_to?(:last_update_created) && self.last_update_created != ""
          doc[:sf_last_update_description] = self.last_update_description if self.respond_to?(:last_update_description)
          return if doc == {}
          self.set(doc)
        end

        # used for update with ruby mongo driver (done especially for migration process)
        def sf_direct_update(collection)
          doc = {}
          doc[:sf_customer] = self.customer.try(:display_name) if self.respond_to?(:customer)
          doc[:sf_person] = self.person.try(:display_name) if self.respond_to?(:person)
          doc[:sf_reported_by] = self.reported_by.try(:display_name) if self.respond_to?(:reported_by)
          doc[:sf_contact] = self.contact.try(:display_name) if self.respond_to?(:contact)
          doc[:sf_service] = self.service.try(:display_name) if self.respond_to?(:service)
          doc[:sf_category] = self.category.try(:display_name) if self.respond_to?(:category)
          doc[:sf_resolution_group] = self.resolution_group.try(:display_name) if self.respond_to?(:resolution_group)
          doc[:sf_assigned_name] = self.solver.try(:display_name) if self.respond_to?(:solver)

          doc[:sf_last_update_user] = self.last_update_user if self.respond_to?(:last_update_user)
          doc[:sf_last_update_created] = self.last_update_created.try(:utc) if self.respond_to?(:last_update_created)
          doc[:sf_last_update_description] = self.last_update_description if self.respond_to?(:last_update_description)
          db = MongoMapper.database
          coll = db[collection]
          coll.update({:_id => self.id}, {"$set" => doc})
        end

      end

    end
  end
end
