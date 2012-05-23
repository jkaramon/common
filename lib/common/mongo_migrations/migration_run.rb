module MongoMigrations

  class MigrationRun
    include MongoMapper::Document
    key :version, String, :required => true
    key :sort_key, Integer, :required => true
    key :db_name, String, :required => true
    key :script, Hash, :required => true
    key :created_at, Time, :required => true, :default => Time.now.utc
    key :status, String, :required => true, :default => :not_started
    many :log_entries, :class_name => 'MongoMigrations::LogEntry' 
    
    def self.last
      sort(:sort_key).last
    end
   
    
    def start!
      self.status = :in_progress
      save!
      info "Migration run ##{version} started"
    end

    def success!
      self.status = :success
      save!
      db_version.update_version(self.version)
      info "Migration run processed sucessfuly" 
    end

    def db_version
      ::MongoMigrations::DbVersion.get
    end

 
    def fail!(exception)
      self.status = :error
      db_version.set_error!
      save!
      log_exception "Error while processing migration run", exception
    end

    def to_hash
      output_hash = {
        :created_at => self.created_at,
        :version => self.version,
        :db_name => self.db_name,
        :script => self.script,
        :status => self.status,
        :log_entries => []
      }
      self.log_entries.each do |log|
        entry_hash = {:severity => log.severity, :message => log.message }
        output_hash[:log_entries] << entry_hash
      end
      output_hash
    end

    def log_exception(message, exception)
      track(:error, "#{message} \n#{exception.message}\nBacktrace:\n#{exception.backtrace.join("\n")}")
    end

    def info(message)
      track(:info, message)
    end

    def track(severity, message)
      log_entries << LogEntry.new(:severity => severity, :message => message)
      save!
    end

  end


end
