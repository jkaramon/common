require 'bson'

class String
  # Sanitizes BSON::ObjectId.
  # If String is invalid BSON::ObjectId, 
  # then returns default_val (defaults to nil)
  def sanitize_oid(default_val = nil)
    BSON::ObjectId.legal?(self) ? self : default_val
  end

 


end
