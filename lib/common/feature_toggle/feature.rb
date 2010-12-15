module FeatureToggle
  class Feature
    attr_accessor :description
    attr_reader :name, :hidden_envs

    def initialize(name)
      raise ArgumentError, "name cannot be nil" if name.nil?
      @name = name.to_s.to_sym
      @hidden_envs = []
    end

    def hidden?(current_env)
      hidden_envs.include?(current_env)
    end

    
    def ==(other)
      return false if other.nil? || !other.is_a?(self.class)
      name == other.name
    end
    
    alias :eql? :==
    
  end
end
