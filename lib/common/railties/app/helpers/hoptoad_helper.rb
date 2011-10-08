module Airbrake
  def hoptoad_js_notifier
    return "" if Rails.env.production? || Rails.env.development? || Rails.env.devcached? || Rails.env.test?
    hoptoad_javascript_notifier
  end
  
end
    
