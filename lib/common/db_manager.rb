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

  # terminate database - create backup
  # @param [String] - id (subdomain) for site
  # @note retrieve actual and backup name for databases, first copy / backup actual database, then drop actual database
  def self.rename_for_backup(site_id)
    original_name = vd_db_name(site_id)
    new_name = backup_vd_db_name(site_id)
    rename_database(original_name, new_name)
  end

  # Renames DB because MongoDb does not support that operation
  # @original_name [String] - database original name
  # @new_name [String] - database new name
  def self.rename_database(original_name, new_name)
    MongoMapper.connection.copy_database(original_name, new_name)
    drop_database(original_name)
  end

  # Prints all databases on current connection to standard output.
  def self.show_dbs
    each_db {|db_name| puts db_name }
  end
  
  def self.site_db_exists?(site_id)
    return false if site_id.blank?
    db_name = vd_db_name(site_id)
    db_exists?(db_name)
  end

  # Checks db existence for given MM connection
  def self.db_exists?(db_name)
    MongoMapper.connection.database_names.include?(db_name)
  end

  # returns database name from site_id
  def self.vd_db_name(site_id)
    return "#{site_id}#{vd_db_suffix}"
  end

  # returns terminated database name from site_id
  def self.backup_vd_db_name(site_id)
    return "backup-#{site_id}#{vd_db_suffix}-#{Time.now.utc.strftime("%Y-%m-%d-%H-%M-%S")}"
  end

  # returns site_id from database name. 
  # Returns nil, if not valid
  def self.vd_site_id(db_name)
    return nil unless vd_db?(db_name)
    return db_name.sub(/#{vd_db_suffix}/, '')
  end

  # returns env suffix from database name. 
  # Returns nil, if not valid
  def self.parse_db_suffix(db_name)
    return "" if db_name.match(/^.*-vd$/)
    data = db_name.match(/^.*-vd(-.*(?!-vd).*)$/)
    data[1] if data.present?
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


  def self.db_suffix
    return "-development" if %w{ development devcached }.include?(env)
    return "" if %w{ production preprod }.include?(env)
    "-#{env}" 
  end


  private

  def self.each_db(&block)
    MongoMapper.connection.database_names.each {|db_name| block.call(db_name) }
  end

  def self.db(db_name)
    MongoMapper.connection.db(db_name)
  end
  
  def self.env
    @env
  end

  def self.env=(environment)
    @env = environment
  end

end
