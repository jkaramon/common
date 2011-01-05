module MongoMigrations

  class MigrationRun
    include MongoMapper::Document
    key :version, Integer, :required => true
    key :db_name, String, :required => true
    key :script, Hash, :required => true
    key :created_at, Time, :required => true, :default => Time.now
    key :status, String, :required => true, :default => :not_started
    many :log_entries, :class_name => 'MongoMigrations::LogEntry' 

    def self.last
      sort(:version).last
    end
    
    def self.last_successful
      where(:status => 'success').sort(:version).last
    end

    def self.any_unresolved?
      unresolved.count > 0
    end

    def self.unresolved
      where(:status => 'error')
    end



    def self.resolve(db)
      db.collection(self.collection_name).update({:status => 'error'}, { '$set' => { status: "error_resolved" } })
    end

    
    def start!
      self.status = :in_progress
      save!
      info "Migration run ##{version} started"
    end

    def success!
      self.status = :success
      save!
      info "Migration run processed sucessfuly" 
    end

    def ignore!
      self.status = :ignored
      save!
      info "Migration run was ignored" 
    end


    def fail!(exception)
      self.status = :error
      save!

      log_exception "Error while processing migration run", exception
    end

    def to_hash
      output_hash = {
        :created_at => self.created_at.time,
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
      track(:error, "#{message} #{exception}")
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
