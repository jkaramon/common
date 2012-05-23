module MongoMigrations
  class DbVersion 
    include MongoMapper::Document
    key :version, String 
    key :has_errors, Boolean, :default => false

    attr_accessor :migration_dir


    def self.format_version(data)
      "#{data[:sprint]}.#{data[:script_number]}"
    end

    def self.parse_version(version)
      raise "Invalid version string." if version.nil?
      data = version.split('.')
      raise "Invalid version string. ''#{version}" if data.length != 2
      { sprint: data.first.to_i, script_number: data.last.to_i }
    end

    def self.sort_key(version)
      parsed_version = self.parse_version(version)
      (parsed_version[:sprint] * 10_000) + parsed_version[:script_number]
    end

   
    def set_error!
      self.class.set({}, :has_errors => true)
      self.has_errors = true
    end

    def clear_error
      self.class.set({}, :has_errors => false)
      self.has_errors = false
    end

    
    def self.get
      version = self.first
      if version.nil?
        raise "Cannot obtain DB version"
      end
      version
    end

    def parsed
      self.class.parse_version(self.version)
    end


    def sort_key
      self.class.sort_key(self.version)
    end

    def update_version(version)
      self.set(:version => version)
    end

    def self.reset_to_latest_sprint(migration_dir)
      version = self.new(:migration_dir => migration_dir)
      version.reset_to_latest_sprint
    end

    def self.set!(version = '0.0') 
      self.delete_all
      self.create(:version => version)
    end

    def reset_to_latest_sprint
      self.class.delete_all
      if self.migration_dir.nil?
        self.migration_dir = Rails.root.join('db', 'migrations')
      end
      runner = MongoMigrations::Runner.new(self.migration_dir)
      latest_script = runner.scripts.last
      if latest_script.present?
        version = latest_script.fetch(:version)
      else
        version = "0.0"
      end
      self.class.create(:version => version)
    end

    


  end
end
