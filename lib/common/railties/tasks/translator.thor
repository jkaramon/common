# encoding: UTF-8
require 'rubygems'
require 'i18n'


class Translator < Thor

  FILE_SPLIT_CHAR = ':'
  KEY_VALUE_SPLIT_CHAR = ';'
  
  desc "export LOCALE [--railsdir]", <<-DESC 
    exports yaml files to CSV for translation
    exported CSV file will be stored in Rails.root/translations.[LOCALE].csv
    CSV is semicolon separated file: [key;value]
        key   .. key contains yaml filename and locale key(separated by colon)
        value .. localized value
    
    Parameters:
      LOCALE .. locale to export [en, cz, ..]
      --railsdir .. Rails app root dir (defaults to current directory)
  DESC
  method_options :railsdir => :string     
  def export(locale = 'en')
    @locale = locale
    @basedir = options[:railsdir] || Dir.pwd 
    FileUtils.mkdir_p  File.join(@basedir, "translations")
    @output_file = File.join(@basedir, "translations/#{@locale}.csv")
    FileUtils.rm @output_file if File.exists?(@output_file)
    @basedir = File.join(@basedir, 'config/locales/')
    glob_pattern = File.join(@basedir, '**/*.yml')
    Dir[glob_pattern].each { |f| export_file f }
    say "Translations are stored in #{@output_file}"
  end

  desc "import CSV [--railsdir]",  <<-DESC 
    imports localized CSV file to yaml.
    imported yaml file will be stored in 
    Rails.root/config/locales/translations.[LOCALE].csv
    
    Input CSV is semicolon separated file: [key;value]
        key   .. key contains yaml filename and locale key(separated by colon)
        value .. localized value 
  
    Parameters: 
      CSV .. UTF8 CSV file to import. Path should be realive to [railsdir]. Filename should have this pattern [LOCALE].csv
      --railsdir .. Rails root dir (defaults to current directory)  
  
  DESC
  method_options :railsdir => :string     
  def import(csv)
    unless File.exists?(csv) 
      say("File '#{csv}' does not exist.")
      return
    end

    @basedir = options[:railsdir] || Dir.pwd 
    @basename = File.basename(csv, '.csv')
    @locale = @basename.split('.').last
    if @locale.empty?
      say("Cannot parse locale from provided csv file")
      return
    end
    output_folder = File.join(@basedir, "config/locales/translations")
    FileUtils.mkdir_p output_folder
    @yaml_file = File.join(output_folder, "#{@basename}.yml")
    return if  File.exists?(@yaml_file) and no?("File '#{@yaml_file}' already exists, overwrite?")
    
    hash = {}
    File.open(csv).each_line do |s|
      deep_merge!(hash, convert_csv_line(s) )
    end
   
    hash = { @locale => hash }

    # We have to convert manually to yaml string because YAML.dump do not support unicode
    data = hash.to_yaml
    data.gsub!(/\\x([0-9a-f]{2})/i) { $1.hex.chr }
    File.open( @yaml_file, 'w' ) do |out|
      out.write(data)
    end

    say "File #{@yaml_file} has been successfully imported"
    

  end


  private

  def debug
    require 'ruby-debug';debugger
  end

  def convert_csv_line(line)
    file, csv_hash_string = line.split(FILE_SPLIT_CHAR, 2)
    keys_string, value = csv_hash_string.split(KEY_VALUE_SPLIT_CHAR, 2)
    keys = keys_string.split('.')
    hash = {}
    value.chomp!
    last_key = ""
    current_hash = previous_hash = hash
    keys.each do |key|
      current_hash[key] = {}
      previous_hash = current_hash
      current_hash = current_hash[key]
      last_key = key
    end
    previous_hash[last_key] = value
    say "#{keys.inspect}  -> #{value}"
    say hash.inspect
    say "-----------------------"
    hash
  end

  def construct_hash()

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
  

  def export_file(file)
    file_key = file.gsub(/#{@basedir}|.yml|.#{@locale}/, "")
    hash = {}
    flatten_hash(hash, YAML.load_file( file )[@locale], "")
    hash.each do |key, value|
      line = "#{file_key}#{FILE_SPLIT_CHAR}#{key}#{KEY_VALUE_SPLIT_CHAR}\"#{value}\"\n"
      File.open(@output_file, 'a') do |f|
        f.write line
        print line
      end
    end
    
  end

  def flatten_hash(new_hash, hash, key_prefix)
    return if hash.nil?
    hash.each do |k, v|
      prefix =  key_prefix + "#{k}."
      if v.is_a?(Hash)
        new_hash.merge(flatten_hash(new_hash, v, prefix))
      else
        new_hash[prefix.chop] = v
      end
    end
  end
  
end


