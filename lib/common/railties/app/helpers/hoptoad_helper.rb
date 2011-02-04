module HoptoadHelper
  def hoptoad_js_notifier
    return "" if Rails.env.production?
    hoptoad_javascript_notifier
  end
  
end
    
