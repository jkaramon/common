module MongoMigrations
  class Runner
    include Logging
    include ErrorNotifier
    attr_reader :script_folder
    attr_reader :scripts
    attr_reader :current_version
    attr_reader :failed_run

    VALID_FILES = "sprint_*/[0-9]*_*.rb"

    def initialize(script_folder = nil)
      @script_folder = script_folder || Rails.root.join('db', 'migrations')
      file_pattern = File.join(@script_folder, VALID_FILES)  
      @script_files = Dir.glob(file_pattern)
      parse_files
    end

    def parse_files
      @scripts = []
      @script_files.each do |f|
        basename = File.basename(f, ".rb")
        splitted_file = basename.split('_', 2)
        script_number = splitted_file.first.to_i
        name = splitted_file.last
        sprint_match = f.match(/sprint_(\d*)\//i)
        if sprint_match.nil?
          raise "Invalid file structure #{f}"
        end
        sprint = sprint_match.captures.first.to_i 
        version = DbVersion.format_version(:sprint => sprint, :script_number => script_number)

        @scripts << {
          :version => version,
          :sort_key => DbVersion.sort_key(version),
          :fullname => f,
          :name => name,
          :script => IO.read(f) 
        }
      end
    end

    def latest_script
      self.scripts.last
    end

    def latest_script_version
      self.latest_script.present? ? self.latest_script.fetch(:version) : "0.0"
    end

    def inspect
      result =  "\nDB: #{MongoMapper.database.name}"
      result << "\nVersion: #{db_version.to_mongo}"
      result << "\nLast processed migration:\n#{MongoMigrations::MigrationRun.last.to_mongo}"
    end
    
    def migrate
      raise "This DB has some errors while previous migration run. Migration process is halted.\n#{self.inspect}" if db_version.has_errors?
      scripts_to_process = @scripts.find_all { |s| s[:sort_key] > db_version.sort_key }   
      scripts_to_process.sort! {|x,y| x[:sort_key] <=> y[:sort_key] }
      scripts_to_process.each do |script|
        @script = script
        mr = run_migration_step
        return false if mr.nil? || mr.status.to_s == 'error'
      end
      clear_cache_db
      true
    end

    def clear_cache_db
      return unless defined?(RAILS_CACHE)
      return if  Rails.cache.nil? or not Rails.cache.respond_to?(:clear)
      Rails.cache.clear
      info "Rails cache content cleared successfully!"
    end

    def db_version
      ::MongoMigrations::DbVersion.get
    end

    def run_migration_step
      run_script
    end

    def run_script
      mr = start_migration_run
      begin
        self.instance_eval @script[:script] 
        mr.success!
      rescue Exception => err
        @failed_run = mr
        mr.fail!(err)
        notify_error(err, mr.to_hash)
      end
      mr
    end

    def start_migration_run
      mr = MigrationRun.new(
        :version => @script[:version],
        :sort_key => @script[:sort_key],
        :db_name => MongoMapper.database.name,
        :script => @script
      )
      mr.start!
      mr
    end

  end



end
