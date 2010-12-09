module Rules
  # defines current control state
  class Rule
    attr_accessor :visibility, :panel_state
    def inspect
      "visibility: #{@visibility}, panel_state: #{@panel_state}"
    end

    def self.enabled
      r = Rule.new
      r.visibility  = :enabled
      r.panel_state = :expanded
      r
    end
    
    def enabled?
      visibility==:enabled
    end
    
    def disabled?
      visibility==:disabled
    end
    
    def hidden?
      visibility==:hidden
    end
    
    def expanded?
      panel_state==:expanded
    end
    
    def collapsed?
      panel_state==:collapsed
    end
    
    
  end
end
