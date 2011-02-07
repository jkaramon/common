module MongoMapper
  module Models
    # Represents state change event. Used by StateHistory plugin
    class StateHistoryRecord  
      include ::MongoMapper::EmbeddedDocument
      key :transition_name, String
      key :old_state, String
      key :new_state, String
      key :updated_at, Time
      key :updated_by, ObjectId


      # creates new record
      def self.create(transition, updated_by)
        record = self.new
        record.update_attributes(transition, updated_by)
        record
      end

      def state_changed?
        old_state != new_state
      end

      

      def update_attributes(transition, updated_by)
        self.transition_name = transition.event
        self.old_state = transition.from_name
        self.new_state = transition.to_name 
        self.updated_at = Time.now
        self.updated_by = updated_by if updated_by.present?
      end

     
    end

  end
end
