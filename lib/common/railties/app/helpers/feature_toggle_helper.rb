module FeatureToggleHelper
  def ftoggle(feature_name, &block)
    if FT.hidden?(feature_name)
      return ""
    else
      return capture(&block)
    end
  end

end
