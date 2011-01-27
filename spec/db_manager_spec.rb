require 'spec_helper'

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
  
  
  
  
end