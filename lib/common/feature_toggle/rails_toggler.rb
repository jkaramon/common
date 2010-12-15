module FeatureToggle
  class RailsToggler < Toggler

    def current_env 
      Rails.env
    end

  end
end
