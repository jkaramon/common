# Hi! I'am rack middleware!
# I was born for return to you valid js on json i18n objects

# My author's name was Aleksandr Koss. Mail him at kossnocorp@gmail.com
# Nice to MIT you!
module Rack
  class I18nJs
    def initialize app, options = {}
      @app = app
      @options = options
    end  

    def call env
      # Valid url is /i18n-<i18n key>-<locale>.<format> where
      # i18n key - yaml branch named "locale.key"
      # locale - locale as is
      # format - js or json
      if data_array = env['PATH_INFO'].scan(/^\/i18n-(\w{1,3})[.](js[on]*)$/)[0]
        locale, type = data_array
       
        # Get yaml 
        json = YAML::load(::File.open("#{Rails.root}/config/locales/js/#{locale}.yml"))[locale]['js'].to_json

        return @app.call env if json == 'null' # Branch not found
        content_type, response = type == 'js' ?
        ['application/javascript', "var i18n = #{json};"] :
        ['application/json', json]

        [200, {'Content-Type' => content_type}, [response]]
      else
        @app.call env
      end
    end
      
  end
end
