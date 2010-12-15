require 'spec_helper'

describe 'Sanitize OID extension'  do
  
  it "nil should return nil" do
    nil.sanitize_oid.should == nil
  end  

  it "nil should return default, if provided" do
    nil.sanitize_oid('default').should == 'default'
  end

  it "should return nil if invalid and no default provided" do
    'invalid'.sanitize_oid.should == nil
  end

  it "should return default if invalid and default value is provided" do
    'invalid'.sanitize_oid('default').should == 'default'
  end

  it "empty string is invalid" do
    ''.sanitize_oid.should == nil
  end

    
  it " '4d01fa8eee7ea017aa00000c' is valid id " do
    '4d01fa8eee7ea017aa00000c'.sanitize_oid.should == '4d01fa8eee7ea017aa00000c'
  end

 
end
