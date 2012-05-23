require 'spec_helper'

describe MongoMigrations::Runner do

  before(:all) do
    @db_name = "__test-common-gem-migrations"
    @base_dir = File.join( File.dirname(__FILE__), 'data')
    MongoMapper.database = @db_name
  end
  
  def init_runner(options = {})
    if !options.include?(:version)
      MongoMigrations::DbVersion.reset_to_latest_sprint(@script_dir)
    else
      MongoMigrations::DbVersion.set!(options[:version])
    end
    @runner = MongoMigrations::Runner.new(@script_dir)
  end

  describe "Script Management" do
    context "Empty2" do
      before(:each) do
        @script_dir = File.join(@base_dir, 'empty')
        init_runner
      end

      it "should locate migration script" do
        @runner.scripts.should have(1).item
      end

      it "should parse version" do
        @runner.scripts.first[:version].should == '3.1'
      end

      it "should parse migration name" do
        @runner.scripts.first[:name].should == "empty_migration"
      end
    end

    context "Invalid names" do
      before(:each) do
        @script_dir = File.join(@base_dir, 'invalid_names')
        init_runner
      end

      it "should ignore invalid migration filenames" do
        @runner.scripts.should have(0).items
      end

    end




  end



  describe "should process migration scripts" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'happy')
      init_runner :version => '0.0'
    end

    it "should process migration scripts" do
      @runner.migrate
    end

  end

  describe "should raise while processing invalid migration scripts" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'error')
      init_runner :version => '0.0'
      @runner.migrate
    end

    it "should process only first two scripts" do
      MongoMigrations::MigrationRun.count.should==2
    end
    it "second migration should fail " do
      MongoMigrations::MigrationRun.where(:status => 'error').count.should==1
    end

    it "first migration should be successful" do
      MongoMigrations::MigrationRun.where(:status => 'success').count.should==1
    end

    it "run after unresolved migration should not process anything" do
      expect {
        @runner.migrate
      }.to raise_error
       
      MongoMigrations::MigrationRun.count.should==2
    end




  end



  describe "should be applied only one time" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'happy')
      init_runner :version => '0.0'
    end

    it "should process each migration only one time" do
      @runner.migrate
      MongoMigrations::MigrationRun.count.should==5
      MongoMigrations::MigrationRun.last.version.should=='2.3'
      @runner.migrate
      MongoMigrations::MigrationRun.count.should==5
    end

  end


  def drop_db
    MongoMapper.connection.drop_database(MongoMapper.database.name)
  end
end
