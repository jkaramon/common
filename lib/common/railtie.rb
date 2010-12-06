require 'common'
require 'rails'
require_relative 'railtie_helper'

module Common 
  class Railtie < Rails::Railtie

    initializer "common.configure_rails_initialization" do |app|
      app.paths.app.views.push RailtieHelper.resolve_railtie('app/views')
      RailtieHelper.copy_static_files_to_web_server_document_root
    end

    config.to_prepare do
      RailtieHelper.init_helpers
    end
  
    rake_tasks { RailtieHelper.load_tasks }
  end
end

