module MongoMigrations

  class MigrationScript
    include MongoMapper::Document
    key :version, Integer, :required => true
    key :script, String, :required => true
    key :created_at, Time, :required => true
    key :status, Symbol, :required => true, :default => :not_started
    many :log_entries, :class_name => '::MongoMigration::LogEntry' 

    def self.last
      sort(:version).last
    end
  end


  class LogEntry
    include MongoMapper::EmbeddedDocument
    key :severity, Symbol
    key :message, String
  end
end
