# class for seeding data from yaml files
module YAMLSeedStore

  private
  
  # Opens yaml file with seed data
  # First it search in data_seed/#{seed_template_name}/[undersored class name]
  # If not find the it fallbacks to data_seed/[undersored class name]
  # returns hash with data from yaml
  def load_from_store(seed_klass)
    raise "Class should implement :seed_template_name accessor" unless self.respond_to?(:seed_template_name)
    root_folder = "#{Rails.root}/db/seed_data"
    name = seed_klass.to_s.underscore 
    filename = "#{name}.yml"
    fullname = File.join(root_folder, seed_template_name, filename )
    fullname = File.join( root_folder, filename )  unless File.exist?( fullname )
    raise "Cannot find  '#{fullname}' file for data seed!"  unless File.exist?( fullname )
    root_data = YAML::load_file( fullname )
    return root_data[name]
  end


end
