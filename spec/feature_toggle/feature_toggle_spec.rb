module FeatureToggle
  require 'spec_helper'

  describe Toggler  do
    FEATURE_CFG = File.join(File.expand_path(File.dirname(__FILE__)), 'toggles.yml')

    before(:each) do
      @toggler = Toggler.load_config(FEATURE_CFG)
    end

    it "should have parsed features" do
      @toggler.features.count.should == 2 
    end

    describe "toggle behaviour" do

      it "should have new_feature hidden in production env" do
        @toggler.current_env = "production"
        @toggler.hidden?(:new_feature).should be_true
      end

      it "should have new_feature shown in non existing env" do
        @toggler.current_env = "non_existing"
        @toggler.hidden?(:new_feature).should be_false
      end

      it "should call shown second_feature " do
        @toggler.current_env = nil
        block_called = false
        @toggler.toggle(:second_feature) do
          block_called = true
        end
        block_called.should be_true
      end

       it "should not call hidden second_feature " do
        @toggler.current_env = "ci"
        block_called = false
        @toggler.toggle(:second_feature) do
          block_called = true
        end
        block_called.should be_false
      end




    end

  end

end
