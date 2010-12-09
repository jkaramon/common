require 'ostruct'

class AppConfigLoader
  def self.load(yaml_config_file, env = Rails.env)
    config = ActiveSupport::HashWithIndifferentAccess.new(YAML.load_file(yaml_config_file))
    env = "common" unless config.include?(env)
    OpenStruct.new(config[env])
  end
end



