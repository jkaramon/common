module FeatureToggle
  def ftoggle(feature_name, &block)
    FT.toggle(feature_name, &block)
  end

end
