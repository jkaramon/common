require 'spec_helper'

describe FeatureSet do
  
  describe "Free edition" do
    subject { FeatureSet.free }
    
    it { subject.notification.should_not be_enabled }
    it { subject.import_email.should_not be_enabled }
    it { subject.api.should_not be_enabled }
    it { subject.portal.should_not be_enabled }
    it { subject.reporting.should_not be_enabled }
    it { subject.storage_size.should be_enabled }
  end

   describe "Lite edition" do
    subject { FeatureSet.lite }
    
    it { subject.notification.should be_enabled }
    it { subject.import_email.should be_enabled }
    it { subject.api.should be_enabled }
    it { subject.portal.should be_enabled }
    it { subject.reporting.should be_enabled }
    it { subject.storage_size.should be_enabled }
  end

  describe "Pro edition" do
    subject { FeatureSet.pro }
    
    it { subject.notification.should be_enabled }
    it { subject.import_email.should be_enabled }
    it { subject.api.should be_enabled }
    it { subject.portal.should be_enabled }
    it { subject.reporting.should be_enabled }
    it { subject.storage_size.should be_enabled }
  end

  describe "Ent edition" do
    subject { FeatureSet.ent }
    
    it { subject.notification.should be_enabled }
    it { subject.import_email.should be_enabled }
    it { subject.api.should be_enabled }
    it { subject.portal.should be_enabled }
    it { subject.reporting.should be_enabled }
    it { subject.storage_size.should be_enabled }
  end



end
