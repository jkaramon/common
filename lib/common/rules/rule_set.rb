
module Rules
  
  # defines rule set
  class RuleSet
    attr_accessor :user, :context, :conditions, :rules, :default_state, :default_panel_state
    cattr_accessor :instance, :dsl_dir
    
    def self.dsl_dir=(value)
      @@dsl_dir = value
    end
    
    def self.dsl_dir
      @@dsl_dir || "#{Rails.root}/config/visibility_rules"
    end
    
    class RuleMapper
      def initialize(set)
        @set = set
      end
      
      
      def enable_if(condition, control_name)
        @set.add_visibility_rule(control_name, :enabled) if condition
      end

      def disable_if(condition, control_name)
        @set.add_visibility_rule(control_name, :disabled) if condition
      end

      def hide_if(condition, control_name)
        @set.add_visibility_rule(control_name, :hidden) if condition
      end
      
      def expand(control_name)
        @set.add_panel_state_rule(control_name, :expanded) 
      end

      def collapse(control_name)
        @set.add_panel_state_rule(control_name, :collapsed) 
      end

      def enable(control_name)
        @set.add_visibility_rule(control_name, :enabled) 
      end
      
      def disable(control_name)
        @set.add_visibility_rule(control_name, :disabled) 
      end
      
      def disable_all
        @set.disable_all
      end

      def disable_all_unless(condition)
        @set.disable_all unless condition
      end

      def enable_all
        @set.enable_all
      end
      
      def expand_all_panels
        @set.expand_all_panels
      end

      def hide(control_name)
        @set.add_visibility_rule(control_name, :hidden) 
      end

    end
    
    # user - current user, context - entity under  rule evaluation - Call, Incident, .. 
    def initialize(user, context, conditions)
      @conditions = conditions
      @user = user
      @context = context
      @rules = {}
      @default_state = :enabled
      @default_panel_state = :collapsed
      
    end
    
    def parse_dsl
      RuleSet.instance = self
      dsl_context_dir = File.join(self.class.dsl_dir, context_class_key(@context.class))
      defaults_dsl_file = File.join(dsl_context_dir, "_defaults.rules")
      dsl_file = File.join(dsl_context_dir, "#{@context.state_name}.rules")
      load(defaults_dsl_file) if File.exists?(defaults_dsl_file)
      load(dsl_file)
    end
    
    def context_class_key(klass)
      klass.to_s.gsub("::", "_").underscore
    end
    # Reads and parses actor definition file. Parsed actors are then available in rule definition 
    def define
      predicates = Object.new
      @conditions.each {|k, v| predicates.class.send(:define_method, "#{k}?") { v } }
      yield RuleMapper.new(self), @conditions, @context
    end
    
    
    def add_visibility_rule(name, state)
     init_rule(name, state).visibility = state
    end
    
    def add_panel_state_rule(name, state)
      init_rule(name, state).panel_state = state
    end
    
    def init_rule(name, state)
      key = "#{context_class_key(@context.class)}_#{name}".to_sym
      @rules[key] = Rule.new unless @rules.include?(key)
      @rules[key]
    end
    
    # disables all non hidden currently defined rules. Sets default_state to :disabled for the not defined rules
    def disable_all
      # rules_to_disable = @rules.select {|key, value| value!=:hidden} 
      #       rules_to_disable.each_key { |key| @rules[key] = :disabled }
      @default_state = :disabled
    end
    
    # enables all rules. Sets default_state to :enabled for the not defined rules
    def enable_all
      # rules_to_disable = @rules.select {|key, value| value!=:hidden} 
      #       rules_to_disable.each_key { |key| @rules[key] = :disabled }
      @default_state = :enabled
    end
    
    # expands all panels. Sets default_state to :expanded for the not defined rules
    def expand_all_panels
      @default_panel_state = :expanded
    end
    
    def default_rule
      r = Rule.new
      r.visibility = @default_state
      r.panel_state = @default_panel_state
      r
    end
    
   
  end


end
