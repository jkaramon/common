module Common
  module RailtieHelper
    
    module_function
    
    # Loads common rake tasks 
    def load_tasks
      each_railtie_file('tasks/*.rake') { |rake_file| load rake_file }   
    end

  

    # Initializes  Railtie view helpers
    def init_helpers
      each_railtie_file('app/helpers/*.rb') do |helper_file| 
        require helper_file; 
        ::ApplicationController.helper(File.basename(helper_file, '.rb').classify.constantize) 
      end
    end
    
    # Iterates files in specified railtie folder
    # Non recursive.
    def each_railtie_file(glob_pattern)
      Dir.glob(resolve_railtie(glob_pattern)) { |fn| yield(fn) }
    end

    # Returns absolute path of the pathname. 
    # pathname is relative to the railtie root
    def resolve_railtie(pathname)
      root = File.join(File.dirname(__FILE__), 'railties')
      File.join(root, pathname)
    end

    # Copies all files from railtie public folder to the 
    # public folder of the Rails application
    def self.copy_static_files_to_web_server_document_root
      public_path = resolve_railtie('public')
      ::Dir[::File.join(public_path, '*')].each do |source_path|
        dest_path = ::File.join(Rails.root, 'public', source_path.gsub(public_path, ''))
        if ::File.directory? source_path
          ::FileUtils.cp_r source_path.concat('/.'), dest_path
        else
          ::FileUtils.cp source_path, dest_path
        end
      end
    end

    

  end
end
