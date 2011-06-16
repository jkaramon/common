require 'spec_helper'

describe AES do
  
  it "should encrypt and decrypt string using AES" do
    AES.decrypt("my_key", AES.encrypt("my_key", "test_string")).should == "test_string"
  end
  
end
