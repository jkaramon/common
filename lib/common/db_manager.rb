require 'mongo_mapper'

class DbManager
  @env = defined?(Rails) ? Rails.env : 'development' 

  # Sets database for site specific entities
  def self.set_vd_database(subdomain)
    MongoMapper.database = vd_db_name(subdomain)
    MongoMapper.database
  end

  # Drops vd databases for the current environment on current connection. Use with caution!!!
  def self.drop_vd_env_databases!
    each_db do |db_name| 
      if  db_name =~ /-vd-#{Rails.env}$/
        MongoMapper.connection.drop_database(db_name)  
      end
    end
  end

  #drop database with db_name
  def self.drop_database(db_name)
    MongoMapper.connection.drop_database(db_name)
  end

  # Prints all databases on current connection to standard output.
  def self.show_dbs
    each_db {|db_name| puts db_name }
  end
  
  def self.site_db_exists?(site_id)
    return false if site_id.blank?
    db_name = vd_db_name(site_id)
    MongoMapper.connection.database_names.include?(db_name)
  end

  # returns database name from site_id
  def self.vd_db_name(site_id)
    return "#{site_id}#{vd_db_suffix}"
  end

  # returns site_id from database name. 
  # Returns nil, if not valid
  def self.vd_site_id(db_name)
    return nil unless vd_db?(db_name)
    return db_name.sub(/#{vd_db_suffix}/, '')
  end

 

  
  
  # iterates throught all vd databases.
  # Block has two arguments:
  # db_name - name of the site db
  # site_id - associated site_id  
  def self.each_vd_db(&block)
    MongoMapper.connection.database_names.each do |db_name|
      block.call(db_name, vd_site_id(db_name)) if vd_site_db?(db_name)
    end
  end
  
  
  
  def self.vd_db?(db_name)
    /[a-zA-Z0-9_-]*#{vd_db_suffix}$/ =~ db_name
  end
  
  def self.vd_site_db?(db_name)
    vd_site_id(db_name).present?
  end

  def self.vd_db_suffix
    "-vd#{db_suffix}"
  end

  private

  def self.each_db(&block)
    MongoMapper.connection.database_names.each {|db_name| block.call(db_name) }
  end

  def self.db(db_name)
    MongoMapper.connection.db(db_name)
  end


  
  def self.db_suffix
    return "-development" if %w{ development devcached }.include?(env)
    return "" if env=="production"
    "-#{env}" 
  end

  def self.env
    @env
  end

  def self.env=(environment)
    @env = environment
  end

end
