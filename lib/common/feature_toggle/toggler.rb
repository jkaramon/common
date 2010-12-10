module FeatureToggle
  class Toggler
    attr_accessor :current_env
    attr_reader :features
    attr_reader :config_file

    def initialize(config_file)
      @config_file = config_file
      @features = {}
      parse_config

    end

    def self.load_config(config_file)
      inst = self.new(config_file)
      inst
    end

    def parse_config
      config = HashWithIndifferentAccess.new(YAML.load_file(config_file))
      config.each do |feature_name, feature_hash|
        f = parse_feature(feature_name, feature_hash)
        features[f.name] = f     
      end
    
    end

    def parse_feature(name, hash)
      hash ||= {}
      f = Feature.new(name)
      f.description = hash[:description]
      hash[:hide_in].split.each do |env|
        f.hidden_envs << env
      end
      f
    end
    
    def hidden?(feature_name)
      f = features[feature_name]
      return false if f.nil?
      f.hidden?(current_env)   
    end
        
    def toggle(feature_name, &block)
      block.call unless hidden?(feature_name)
    end




  end
end
