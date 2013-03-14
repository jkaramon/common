

module Rules
  
  # parses and evaluates form visibility rules
  class Engine
    
    attr_accessor :user, :context, :conditions, :rule_set, :rules
    
    cattr_accessor :logger

    
    # user - current user, context - entity under  rule evaluation - Call, Incident, .. 
    def initialize(user, context)
      return unless context.respond_to?(:state_name)
      debug "Initialize engine ..."
      start_time = Time.now
      @user = user
      @context = context
      @conditions = parse_conditions
      @rule_set = RuleSet.new(@user, @context, @conditions)
      @rule_set.parse_dsl
      @rules = @rule_set.rules
      debug "Done in #{ Time.now - start_time } s."
      @total_evaluation_time = 0
    end
    
    def parse_conditions
      condition_set = ConditionSet.new(@user, @context)
      condition_set.parse_dsl
      condition_set.conditions
    end
    
    def parse_rules
      start_time = Time.now
      RuleSet.new(@user, @context, @conditions)
      @rule_set.parse_dsl
    end
    
    # returns visibility state for given control according to the rule definitions.
    def evaluate(control_name)
      return Rule.enabled if @rules.nil?
      start_time = Time.now
      rule_name = control_name
      if control_name.to_s.end_with?('_id') && !@rules.has_key?(rule_name)
        rule_name = control_name.to_s.gsub(/_id$/, "").to_sym
        spent_time =  Time.now - start_time
        @total_evaluation_time += spent_time
        debug ":#{control_name} rule is not defined, trying #{rule_name}"
      end
      ret_val = @rules.fetch(rule_name, @rule_set.default_rule )
      if self.class.logger
        spent_time =  Time.now - start_time
        @total_evaluation_time += spent_time
        debug ":#{rule_name}  evaluated as :#{ret_val.inspect}"
        debug "Spent: #{ spent_time } s, accumulated: #{ @total_evaluation_time }s"
      end
      ret_val
    end
    
    def debug(msg) 
      self.class.logger.debug(msg) if self.class.logger
    end
    
  end

end
