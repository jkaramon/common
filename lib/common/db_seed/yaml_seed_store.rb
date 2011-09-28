# class for seeding data from yaml files
module YAMLSeedStore

  private
  
  # Opens yaml file with seed data
  # First it search in data_seed/#{seed_template_name}/[undersored class name]
  # If not find the it fallbacks to data_seed/[undersored class name]
  # returns hash with data from yaml
  def load_from_store(seed_klass)
    raise "Class should implement :seed_template_name accessor" unless self.respond_to?(:seed_template_name)
    name = seed_klass.to_s.underscore.gsub("/","__") 
    fullname = store_path(name, seed_template_name)
    fullname = store_path(name) unless File.exist?( fullname )
    raise "Cannot find  '#{fullname}' file for data seed!"  unless File.exist?( fullname )
    root_data = YAML::load_file( fullname )
    return root_data[name]
  end

  # Rewrites yaml file with seed data
  # First it search in data_seed/#{seed_template_name}/[undersored class name]
  # returns hash with data from yaml
  def save_to_store(seed_klass, data)
    raise "Class should implement :seed_template_name accessor" unless self.respond_to?(:seed_template_name)
    name = seed_klass.to_s.underscore.gsub("/","__")
    fullname = store_path(name, seed_template_name)
    File.open(fullname, 'w') {|f| f.write(data) }
  end

  def store_path(name, template_name = '')
    root_folder = "#{Rails.root}/db/seed_data"
    filename = "#{name}.yml"
    File.join(root_folder, template_name, filename)
  end


end
