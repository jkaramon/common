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
      # Valid url is /i18n-<locale>.js where
      # i18n key - yaml branch named "locale.key"
      # locale - locale as is
      if data_array = env['PATH_INFO'].scan(/^\/i18n-(\w{1,3})[.]js$/)[0]
        locale = data_array.first
        # Get yaml 
        loc_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/#{locale}.yml"))[locale]['js']
        formats_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/formats-#{locale}.yml"))[locale]['js']

        json = loc_data.merge(formats_data).to_json
  
        return @app.call env if json == 'null' # Branch not found
        content_type = 'application/javascript'
        response =  "var i18n = #{json};"
        [200, {'Content-Type' => content_type}, [response]]
      else
        @app.call env
      end
    end


      
  end
end
