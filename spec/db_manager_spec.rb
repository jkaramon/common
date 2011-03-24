require 'spec_helper'
require 'timecop'

describe DbManager do
  
  it "should return correct site database_name when site is defined" do
    DbManager.env = "test_env"
    DbManager.vd_db_name("mycompany").should == "mycompany-vd-test_env"
  end
  
  
  it "should return correct site database_name for production env" do
    DbManager.env = "production"
    DbManager.vd_db_name("mycompany").should == "mycompany-vd"
  end

  it "should return correct site database_name for production env" do
    DbManager.env = "production"
    DbManager.vd_db_name("emission--s-r-o").should == "emission--s-r-o-vd"
  end
  
  
  it "should return correct site database_name for devcached env" do
    DbManager.env = "devcached"
    DbManager.vd_db_name("mycompany").should == "mycompany-vd-development"
  end
  
  it "should compose correct preprod vd_db_suffix" do
    DbManager.env = "preprod"
    DbManager.vd_db_suffix.should == "-vd"
  end


  it "should evaluate site db correctly" do
    DbManager.env = "test"
    DbManager.vd_site_db?("rspec-vd-test").should be_true
  end
  
  it "should generate correct backup name" do
    DbManager.env = "production"
    Timecop.freeze(Time.utc(2010,11,10,14,8,3)) do
      DbManager.backup_vd_db_name("emission--s-r-o").should == "backup-emission--s-r-o-vd-2010-11-10-14-08-03"
    end
  end
  
end
