require 'spec_helper'

describe 'Feature' do

  before(:each) do
  end
  describe Feature do
    subject { Feature.new(:free) }
    it { should_not be_enabled }
    it { subject.constraints_info.should == "" }
  end

 
  
  describe NotificationFeature do
    subject { NotificationFeature.new(:free, :enabled => true, :max_emails => 1_000) }
    it { subject.constraints_info.should == "1,000 emails/month" }
  end

   describe "Disabled NotificationFeature" do
    subject { NotificationFeature.new(:free, :enabled => false, :max_emails => 1_000) }
    it { subject.disabled_info.should == "Notifications are not available in Free edition.  Please consider upgrading to a higher edition." }
  end


  describe "Exceeded NotificationFeature" do
    subject { NotificationFeature.new(:free, :enabled => false, :max_emails => 1_000) }
    it { subject.exceed_info.should == "Your site sent more than <em>1,000</em> emails/month (limit for Free edition). No more notifications will be sent this month. Please consider upgrading to a higher edition." }
  end


  describe ImportEmailFeature do
    subject { ImportEmailFeature.new(:free, :enabled => true, :import_frequency => 10.minutes) }
    it { subject.constraints_info.should == "10 min" }
  end

  describe ReportingFeature do
    it { ReportingFeature.new(:free, :enabled => true, :custom_reports_enabled => true).constraints_info.should == "" }
    it { ReportingFeature.new(:free, :enabled => true, :custom_reports_enabled => false).constraints_info.should == "no custom reports" }

  end

  describe StorageSizeFeature do
    subject { StorageSizeFeature.new(:free, :enabled => true, :max_size_in_bytes => 10.gigabytes) }
    it { subject.constraints_info.should == "10 GB" }
  end



end
