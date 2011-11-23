require 'spec_helper'

describe Edition do
  describe "Free" do
    subject { Edition.free }

    it { subject.abbreviation.should == "Free" }
    it { subject.name.should == "Free" }
    it { subject.price_per_month_formatted.to_s.should == "$0" }
    it { subject.features.notification.should be_disabled }
  end


  describe "Lite" do
    subject { Edition.lite }

    it { subject.abbreviation.should == "Lite" }
    it { subject.name.should == "Lite" }
    it { subject.price_per_month_formatted.to_s.should == "$29" }
    it { subject.features.notification.max_emails.should == 1_000 }
  end


  describe "Pro" do
    subject { Edition.pro }

    it { subject.abbreviation.should == "Pro" }
    it { subject.name.should == "Professional" }
    it { subject.price_per_month_formatted.to_s.should == "$119" }
    it { subject.features.notification.max_emails.should == 10_000 }
  end


  describe "Ent" do
    subject { Edition.ent }

    it { subject.abbreviation.should == "Ent" }
    it { subject.name.should == "Enterprise" }
    it { subject.price_per_month_formatted.to_s.should == "$199" }
    it { subject.features.notification.max_emails.should == 100_000 }  end





end
