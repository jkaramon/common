# Represents a current database version.
# In future, this document should store informations about processed DB migrations. 
class DBVersion
  include MongoMapper::Document
  
  key :database_created_at, Time, :default => Time.now, :required => true
  key :version, Integer, :default => 0, :required => true
end