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
        selected = "default"
        user_id = env['rack.session']['warden.user.user.key']
        
        unless user_id.nil?
          user = User.find(user_id[1].to_s)
          unless user.user_settings.nil?
            selected = user.user_settings.time_format
          end
        end

        # Get yaml
        loc_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/en.yml"))['en']['js']
        formats_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/formats-en.yml"))['en']['js']

        # if locale is not default (not 'en') - load proper file and merge it with default file
        # this should prevent from missing translations in js (not defined in non-default files)
        unless locale == 'en'
          selected_loc_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/#{locale}.yml"))[locale]['js']
          deep_merge!(loc_data, selected_loc_data)
          selected_formats_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/formats-#{locale}.yml"))[locale]['js']
          deep_merge!(formats_data, selected_formats_data)
        end

        if formats_data.nil?
          json = loc_data.to_json
        else
          selected_time_format = {"formats"=> {"time" => formats_data['formats']['time'][selected] }}
          json = loc_data.merge(selected_time_format).to_json
        end

        return @app.call env if json == 'null' # Branch not found

        content_type = 'application/javascript'
        response =  "var i18n = #{json};"
        [200, {'Content-Type' => content_type}, [response]]
      else
        @app.call env
      end
    end

    def deep_merge!(first, second)
      second.each_pair do |k,v|
        if first[k].is_a?(Hash) and second[k].is_a?(Hash)
          deep_merge!(first[k], second[k])
        else
          first[k] = second[k]
        end
      end
    end

  end
end
