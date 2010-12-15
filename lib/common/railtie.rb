require 'common'
require 'rails'
require_relative 'railtie_helper'

module Common 
  class Railtie < Rails::Railtie


   
    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.orm               :mongo_mapper
      #   g.template_engine :erb
      #   g.test_framework  :test_unit, :fixture => true
    end 

   

    
    # Run before first initializer
    config.before_initialize do
      ::AppConfig = AppConfigLoader.load("#{Rails.root}/config/app_config.yml")
      ::SecureConfig = AppConfigLoader.load("#{Rails.root}/config/secure_config.yml")
      ::FT = FeatureToggle::RailsToggler.load_config("#{Rails.root}/config/toggles.yml")
      DbConnection.set
    end

    initializer "common.feature_toggler" do
          end

    initializer "common.register_middlewares" do |app|
      app.middleware.use "Rack::I18nJs"
      app.middleware.use "Rack::MongoMapperCleanup"
    end


    initializer 'common.formtastic' do
      Formtastic::SemanticFormBuilder.default_text_field_size = 20
      Formtastic::SemanticFormBuilder.required_string = ""
      Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
    end

   
    initializer 'common.action_mailer' do
      # Email settings
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.raise_delivery_errors = true

      ActionMailer::Base.default_url_options[:host] = AppConfig.mailer[:default_url_options][:host]
      ActionMailer::Base.perform_deliveries = false

      ActionMailer::Base.smtp_settings = SecureConfig.smtp_settings.symbolize_keys

      if Rails.env.production? || Rails.env.ci? || Rails.env.night?
        ActionMailer::Base.delivery_method = :smtp
        ActionMailer::Base.perform_deliveries = true    
      end
    end

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

