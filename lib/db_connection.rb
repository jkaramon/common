module DbConnection
  
  
  def self.set
    db_config = load_config(File.join(Rails.root, "/config/mongodb.yml"))
 
    mongo = db_config[Rails.env]
    if mongo.include?('config_file') && File.exists?(mongo['config_file'])
      Rails.logger.debug "Establishing DB connection from '#{mongo['config_file']}' "
      mongo = load_config(mongo['config_file'])
    end
    hosts = mongo['hosts']
    
    Rails.logger.debug "Trying to connect to the  '#{hosts.inspect}' "
    MongoMapper.connection = Mongo::Connection.multi(hosts, :logger => Rails.logger)
        
  end

  def self.load_config(filename)
    YAML::load(File.read(filename))
  end
  
  
end

