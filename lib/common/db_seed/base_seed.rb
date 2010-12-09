require_relative 'db_version'
require_relative 'yaml_seed_store'

# Base abstract class for data seeding.
class BaseSeed

  def seed
    raise "Implement in subclass"  
  end

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger || Rails.logger
  end


  private
  
  def seed_db_version
    DBVersion.create!
  end
  
  
  def drop_empty_db
    db = MongoMapper.database
    if db.collections.count == 0
      log "Deleting Db '#{db.name}' because is empty"
      MongoMapper.connection.drop_database db.name 
    end
  end
  
 

  def get_collection_data(hash, klass, key_attr)
    if hash.nil?
      hash = HashWithIndifferentAccess.new
      klass.all.each do |item|
        hash[item[key_attr].to_s] = item
      end
    end
    hash
  end

  def log_progress(progress_message)
    log "Starting #{progress_message}"
    begin
      yield
      log "#{progress_message} finished successfuly."
    rescue
      log "Error while #{progress_message}."
      raise
    end
  end

  def log(message)
    logger.info message
  end

  

  def collection_non_empty?(doc_klass)
    doc_klass.collection.count>0
  end

  def seed_non_empty(doc_klass)
    if collection_non_empty?(doc_klass)
      log "Skipping seeding #{doc_klass} because is non empty"
    else
      log_progress "seeding #{doc_klass}" do
        yield
      end
    end
  end
  
  

  def raw_seed(klass, &block)
    log_progress "seeding #{klass}" do
      block.call(klass)
    end
  end



  def seed_data(klass, &block)
    log_progress "seeding #{klass}" do
      parse_data(load_from_store(klass), klass, &block)
    end
  end

  def seed_tree(klass, &block)
    log_progress "seeding #{klass}" do
      parse_tree_model(load_from_store(klass), nil, klass)
    end
  end


  def parse_data(data, klass, &block)
    if data.nil?
      log "Source for #{klass} is empty, skipping ..." 
      return
    end
    data.each do |arr|
      obj = klass.new(arr)
      if block_given?
        block.call(obj)
      end
      unless obj.save
        raise "Error while saving #{klass} entity.\nValidation Errors:#{obj.errors.inspect}"
      end
      
    end
  end


  # parses model represented as tree
  def parse_tree_model(data, parent, klass)
    data.each do |node|
      case
        when node.is_a?(Hash) then # composite node
          node.each do |key, value|
            new_parent = klass.new( :name => key, :parent_id => parent.try(:id))
            new_parent.do_create!
            parse_tree_model(value, new_parent, klass)
          end
        when node.is_a?(String) then # leaf node
          item = klass.new(:name => node, :parent_id => parent.try(:id))
          item.do_create!
      end
    end
  end



end
