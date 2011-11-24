require 'spec_helper'

describe 'Feature' do

  before(:each) do
  end
  describe Feature do
    subject { Feature.new }
    it { should_not be_enabled }
    it { subject.constraints_info.should == "" }
  end
  
  describe NotificationFeature do
    subject { NotificationFeature.new(:enabled => true, :max_emails => 1_000) }
    it { subject.constraints_info.should == "1,000 emails/month" }
  end

  describe ImportEmailFeature do
    subject { ImportEmailFeature.new(:enabled => true, :import_frequency => 10.minutes) }
    it { subject.constraints_info.should == "10 min" }
  end

  describe ReportingFeature do
    it { ReportingFeature.new(:enabled => true, :custom_reports_enabled => true).constraints_info.should == "" }
    it { ReportingFeature.new(:enabled => true, :custom_reports_enabled => false).constraints_info.should == "no custom reports" }

  end

  describe StorageSizeFeature do
    subject { StorageSizeFeature.new(:enabled => true, :max_size_in_bytes => 10.gigabytes) }
    it { subject.constraints_info.should == "10 GB" }
  end



end
