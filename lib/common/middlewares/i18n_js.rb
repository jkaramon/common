require 'digest/md5'
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
        req = Rack::Request.new(env)
        translation_mode = req.params.include?("translation_mode");

        if translation_mode
          loc_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/en.yml"))['en']['js']
          formats_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/formats-en.yml"))['en']['js']
          selected_time_format = {"formats"=> {"time" => formats_data['formats']['time'][selected] }}
          en_json = loc_data.merge(selected_time_format).to_json
          loc_json = '{}'
          unless locale == 'en'
            selected_loc_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/#{locale}.yml"))[locale]['js']
            selected_formats_data = YAML::load(::File.open("#{Rails.root}/config/locales/js/formats-#{locale}.yml"))[locale]['js']
            selected_time_format = {"formats"=> {"time" => selected_formats_data['formats']['time'][selected] }}
            loc_json = selected_loc_data.merge(selected_time_format).to_json
          end
          data = "\ni18n.en_data = #{en_json}";
          data += "\ni18n.current_loc_data = #{loc_json}";
        else
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
          data = "i18n.data = #{json};";
        end




        content_type = 'application/javascript'
        response =  "var i18n = i18n || {};\n#{data}"
        headers = {}
        headers['Content-Type'] = content_type
        headers['Cache-Control'] = "max-age=31536000, public"
        headers['Etag'] = Digest::MD5.hexdigest(response)
        [200, headers, [response]]
      else
        @app.call env
      end
    end

    # method deep_merge! should merge 'second' hash into the first one recursively
    # final result: first hash contains
    #   - all its original keys with values taken from second hash (if second hash contains the key)
    #   - additional keys form second hash (not included in first) with their values
    # test: common/spec/middlewares/i18n_js_spec.rb
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
