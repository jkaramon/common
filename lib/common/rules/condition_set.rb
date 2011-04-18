
module Rules
  # defines named condition set for further use in rule definition
  class ConditionSet
    attr_accessor :user, :context, :conditions
    cattr_accessor :instance, :dsl_dir
    
    def self.dsl_dir=(value)
      @@dsl_dir = value
    end
    
    def self.dsl_dir
      @@dsl_dir || "#{Rails.root}/config/visibility_rules"
    end
    
    class ConditionMapper
      def initialize(set)
        @set = set
      end
      
      def condition(name, &has_role_predicate)
        @set.add_condition(name, has_role_predicate.call)
      end
    end
    
    # user - current user, context - entity under  rule evaluation - Call, Incident, .. 
    def initialize(user, context)
      @conditions = {}
      @user = user
      @context = context
    end
    
    def parse_dsl
      ConditionSet.instance = self
      context_class = context.class
      begin
        dsl_file = File.join(self.class.dsl_dir, "#{context_class_key(context_class)}.conditions")
        context_class = context_class.superclass 
      end while not (File.exists?(dsl_file) || context_class.nil? )
      load(dsl_file)
    end

    def context_class_key(klass)
      klass.to_s.demodulize.underscore
    end

    
    # Reads and parses actor definition file. Parsed actors are then available in rule definition 
    def define
      yield ConditionMapper.new(self), @user, @context
    end
    
    
    def add_condition(name, has_role)
      @conditions[name] = has_role
    end
    
  end


end
