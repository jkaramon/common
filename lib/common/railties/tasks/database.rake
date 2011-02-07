namespace :db do
  
  desc 'Seeds demo data and applies db migrations'
  task :demo_seed_and_migrate => [:demo_seed, :demo_migrate]

  desc 'Applies all db migrations'
  task :demo_migrate => [:environment] do
    if production_env?
      puts "ERROR - you cannot run demo migrations for production environment!"
      exit 1
    end
    Jobs::DbMigrationProcessor.execute 
  end
   
  desc 'Seeds demo data'
  task :demo_seed => [:environment] do
    file = 'demo_seeds.rb'
    if production_env?
      puts "ERROR - you cannot run demo seed for production environment! Run db:seed instead"
      exit 1
    end
    # Speed-up demo seed by including IdentityMap 
    MongoMapper::Document.append_inclusions(MongoMapper::Plugins::IdentityMap)
    seed_file = File.join(Rails.root, 'db', file)
    load(seed_file) if File.exist?(seed_file)
  end
  
  desc 'Drops all site databases'
  task :drop_env_databases => [:environment] do
    if production_env?
      puts "ERROR - you cannot run this task in production environment!"
      exit 1
    end
    DbManager.drop_vd_env_databases!
  end

  def production_env?
     Rails.env.preprod? || Rails.env.production?
  end

end


