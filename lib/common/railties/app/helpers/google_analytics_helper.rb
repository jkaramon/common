module GoogleAnalyticsHelper
  def google_analytics_js
    return "" if AppConfig.google_analytics_ua_number.nil?
    javascript_tag(google_analytics_js_script(AppConfig.google_analytics_ua_number))
  end
  
  def google_analytics_js_script(ua_number)
    <<-JAVASCRIPT
      var _gaq = _gaq || []; 
      _gaq.push(['_setAccount', '#{ua_number}']); 
      #{set_domain}
      #{add_username_var}
      #{add_company_name_var}
      _gaq.push(['_trackPageview']); 

      (function() { 
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; 
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; 
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); 
      })();
    JAVASCRIPT
  end
  
  def set_domain
    return "" if AppConfig.google_analytics_domain.nil?
    "_gaq.push(['_setDomainName', '#{AppConfig.google_analytics_domain}']);\n" 
  end
  
  def add_username_var
    return "" if current_user.try(:username).blank?
    add_custom_var("username", current_user.username, 1)
  end
  
  def add_company_name_var
    return "" if current_user.try(:sd_provider).nil?
    add_custom_var("companyname", current_user.sd_provider.name, 2)
  end
  
  
  def add_custom_var(name, value, slot)
    sanitized_value = value.gsub("'", "")
    "_gaq.push(['_setCustomVar', #{slot}, '#{name}', '#{sanitized_value}']);"
  end
end
    
