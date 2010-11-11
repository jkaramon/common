module MongoMigrations
  class LogEntry
    include MongoMapper::EmbeddedDocument
    key :severity, String 
    key :message, String
    key :created_at, Time, :default => Time.now
  end
end
