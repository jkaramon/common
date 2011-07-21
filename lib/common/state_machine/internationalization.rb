module StateMachine

  module Internationalization
    extend ActiveSupport::Concern

    module InstanceMethods
      
      def state_display_name
        I18n.translate("state_names.#{self.state}")
      end
      
    end
    
  end
end
