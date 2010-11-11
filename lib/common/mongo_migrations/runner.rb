module MongoMigrations
  class Runner
    include Logging
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




    def migrate
      scripts_to_process = @scripts.find_all { |s| s[:version] > last_version }   
      scripts_to_process.sort! {|x,y| x[:version] <=> y[:version] }

      scripts_to_process.each do |script|
        @last_migration = MigrationRun.last
        @script = script
        mr = run_migration_step
        return false if mr.status.to_s != 'success'
      end
      true
    end

    def last_version
      return 0 if @last_migration.nil?
      @last_migration.version
    end

    def last_migration_failed?
      if @last_migration.nil?
        return false
      end
      @last_migration.status == 'error'
    end



    def run_migration_step
      if last_migration_failed?
        info "Migration cannot be processed because last run failed"
      end
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
