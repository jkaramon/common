

module Rules
  
  # parses and evaluates form visibility rules
  class Engine
    
    attr_accessor :user, :context, :conditions, :rule_set, :rules
    
    cattr_accessor :logger
    
    # user - current user, context - entity under  rule evaluation - Call, Incident, .. 
    def initialize(user, context)
      return unless context.respond_to?(:state_name)
      @user = user
      @context = context
      @conditions = parse_conditions
      @rule_set = RuleSet.new(@user, @context, @conditions)
      @rule_set.parse_dsl
      @rules = @rule_set.rules
    end
    
    def parse_conditions
      condition_set = ConditionSet.new(@user, @context)
      condition_set.parse_dsl
      condition_set.conditions
    end
    
    def parse_rules
      RuleSet.new(@user, @context, @conditions)
      @rule_set.parse_dsl
    end
    
    # returns visibility state for given control according to the rule definitions.
    def evaluate(control_name)
      return Rule.enabled if @rules.nil?
      rule_name = control_name
      if control_name.to_s.end_with?('_id') && !@rules.has_key?(rule_name)
        rule_name = control_name.to_s.gsub(/_id$/, "").to_sym
        self.class.logger.debug(":#{control_name} rule is not defined, trying #{rule_name}") if self.class.logger
      end
      ret_val = @rules.fetch(rule_name, @rule_set.default_rule )
      self.class.logger.debug(":#{rule_name}  evaluated as :#{ret_val.inspect}") if self.class.logger
      ret_val
    end
    
   
    
  end

end
