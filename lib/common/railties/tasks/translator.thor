require 'rubygems'
require 'i18n'

class Translator < Thor
  
  FILE_SPLIT_CHAR = ':'
  KEY_VALUE_SPLIT_CHAR = ';'
  
  desc "export LOCALE [--basedir]", 
    "export yaml files to CSV for translation 
    LOCALE .. locale to export 
    --railsdir .. Rails app root dir (defaults to current directory)"
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

  desc("import CSV [--basedir]",   
       "import localized CSV file to yaml.   
       CSV .. CSV file to import
       --railsdir .. Rails root dir (defaults to current directory)  ")
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
      hash.merge!(convert_csv_line(s) )
    end
    
    hash = { @locale => hash }
    
    File.open( @yaml_file, 'w' ) do |out|
      YAML.dump( hash, out )
    end

    say "File #{@yaml_file} has been successfully imported"
    

  end


  private

  def debug
    require 'ruby-debug';debugger
  end

  def convert_csv_line(line)
    hash = {}
    file, csv_hash_string = line.split(FILE_SPLIT_CHAR, 2)
    keys_string, value = csv_hash_string.split(KEY_VALUE_SPLIT_CHAR, 2)
    keys = keys_string.split('.')
    current_hash = hash
    previous_hash = hash
    last_key = ""
    
    keys.each do |key|
      previous_hash = current_hash
      last_key = key
      current_hash[key] = {}
      current_hash = current_hash[key] if current_hash
    end
    previous_hash[last_key] = value
    hash
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


