require 'rubygems'
require 'mongo_mapper'

class DbManager
  @env = Rails.env 

  # Sets database for site specific entities
  def self.set_vd_database(subdomain)
    MongoMapper.database = vd_db_name(subdomain)
    MongoMapper.database
  end

  # Drops vd databases for the current environment on current connection. Use with caution!!!
  def self.drop_vd_env_databases!
    each_db do |db_name| 
      puts "Listing Database '#{db_name}'"
      if  db_name =~ /-vd-#{Rails.env}$/
        Rails.logger.info "Dropping database '#{db_name}'"
        puts "Dropping database '#{db_name}'"
        MongoMapper.connection.drop_database(db_name)  
      end
    end
  end

  #drop database with db_name
  def self.drop_database(db_name)
    Rails.logger.info "Dropping database '#{db_name}'"
    MongoMapper.connection.drop_database(db_name)
  end

  # Prints all databases on current connection to standard output.
  def self.show_dbs
    each_db {|db_name| puts db_name }
  end


  def self.vd_db_name(site_id)
    return "#{site_id}-vd#{db_suffix}"
  end

  def self.vd_site_id(db_name)
    #only work version ( nasty and wrong ), do not use 
    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd/)
    return nil unless rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd-cucumber/)
    return nil if rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd-production/)
    return db_name[0,db_name.length-14] if rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd-development/)
    return db_name[0,db_name.length-15] if rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd-test_env/)
    return db_name[0,db_name.length-12] if rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd-test/)
    return db_name[0,db_name.length-8] if rgxp === db_name

    rgxp = Regexp.new(/[a-zA-Z0-9_-]*-vd/)
    return db_name[0,db_name.length-3] if rgxp === db_name
  end

  private


  def self.each_db(&block)
    MongoMapper.connection.database_names.each {|db_name| block.call(db_name) }
  end

  def self.db(db_name)
    MongoMapper.connection.db(db_name)
  end


  def self.vd_db_name(site_id)
    return "#{site_id}-vd#{db_suffix}"
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
