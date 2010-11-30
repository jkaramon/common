module MongoMigrations
  class Runner
    include Logging
    include ErrorNotifier
    attr_reader :script_folder
    attr_reader :scripts
    attr_reader :current_version
    attr_reader :failed_run

    VALID_FILES = "[0-9]*_*.rb"

    def initialize(script_folder)
      @script_folder = script_folder
      file_pattern = File.join(@script_folder, VALID_FILES)  
      @script_files = Dir.glob(file_pattern)
      parse_files
    end

    def parse_files
      @scripts = []
      @script_files.each do |f|
        basename = File.basename(f, ".rb")
        splitted = basename.split('_', 2)
        version = splitted.first.to_i
        name = splitted.last

        @scripts << {
          :version => version,
          :fullname => f,
          :name => name,
          :script => IO.read(f) 
        }
      end
    end




    def migrate(apply_scripts = true)
      @apply_scripts = apply_scripts
      scripts_to_process = @scripts.find_all { |s| s[:version] > last_version }   
      scripts_to_process.sort! {|x,y| x[:version] <=> y[:version] }
      scripts_to_process.each do |script|
        @script = script
        mr = run_migration_step
        return false if mr.nil? || mr.status.to_s == 'error'
      end
      true
    end

    def last_version
      return 0 if last_migration.nil?
      last_migration.version
    end

    def last_migration
      MigrationRun.last
    end

    def any_migration_unresolved?
      MigrationRun.any_unresolved?
    end



    def run_migration_step

      if any_migration_unresolved?
        info "Migration cannot be processed because some of the previous runs are unresolved"
        return
      end
      run_script
    end

    def run_script
      mr = start_migration_run
      begin
        if @apply_scripts
          self.instance_eval @script[:script] 
          mr.success!
        else
          info "Migration is run in replay mode. No script will be processed but version will be updated to the latest migration script"
          mr.ignore!
        end

      rescue Exception => err
        notify_error(err)
        @failed_run = mr
        mr.fail!(err)
      end
      mr
    end

    def start_migration_run
      mr = MigrationRun.new(
        :version => @script[:version],
        :db_name => MongoMapper.database.name,
        :script => @script
      )
      mr.start!
      mr
    end

  end



end
