require 'common/railtie_helper'

desc "Rake tasks to sync common assets"
namespace :assets do
  
  
  desc "Copies all assets from common public folder to the public folder of the rails project"
  task :copy do
    Common::RailtieHelper.copy_static_files_to_web_server_document_root
  end
  
    
end

task :less => 'less:screen'
