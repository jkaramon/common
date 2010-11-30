require 'spec_helper'

describe MongoMigrations::Runner do

  before(:all) do
    @db_name = "__test-common-gem-migrations"
    @base_dir = File.join( File.dirname(__FILE__), 'data')
    MongoMapper.database = @db_name
  end

  describe "Script Management" do
    context "Empty2" do
      before(:each) do
        @script_dir = File.join(@base_dir, 'empty')
        @runner = MongoMigrations::Runner.new(@script_dir)
      end

      it "should locate migration script" do
        @runner.scripts.should have(1).item
      end

      it "should parse version" do
        @runner.scripts.first[:version].should == 1
      end

      it "should parse migration name" do
        @runner.scripts.first[:name].should == "empty_migration"
      end
    end

    context "Invalid names" do
      before(:each) do
        @script_dir = File.join(@base_dir, 'invalid_names')
        @runner = MongoMigrations::Runner.new(@script_dir)
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
      @runner = MongoMigrations::Runner.new(@script_dir)
    end

    it "should process migration scripts" do
      @runner.migrate
    end

  end

  describe "should raise while processing invalid migration scripts" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'error')
      @runner = MongoMigrations::Runner.new(@script_dir)
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
      @runner.migrate
      MongoMigrations::MigrationRun.count.should==2
    end




  end



  describe "should process replay only mode" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'error')
      @runner = MongoMigrations::Runner.new(@script_dir)
    end

    it "should process migration scripts in replay mode and set ignored status" do
      @runner.migrate false
      MongoMigrations::MigrationRun.where(:status => 'ignored').count.should==3
    end

  end

  describe "should be applied only one time" do
    before(:all) do
      drop_db
      @script_dir = File.join(@base_dir, 'happy')
      @runner = MongoMigrations::Runner.new(@script_dir)
    end

    it "should process each migration only one time" do
      @runner.migrate
      MongoMigrations::MigrationRun.count.should==2
      MongoMigrations::MigrationRun.last.version.should==2
      @runner.migrate
      MongoMigrations::MigrationRun.count.should==2
    end

  end


  def drop_db
    MongoMapper.connection.drop_database(MongoMapper.database.name)
  end
end
