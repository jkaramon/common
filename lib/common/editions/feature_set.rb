class FeatureSet
  attr_writer :notification
  attr_writer :import_email 
  attr_writer :api
  attr_writer :portal
  attr_writer :reporting
  attr_writer :storage_size


  def self.definitions
    {
      :free => {
        :notification => { :enabled => false },
        :import_email => { :enabled => false },
        :api => { :enabled => false },
        :portal => { :enabled => false },
        :reporting => { :enabled => false },
        :storage_size => { :enabled => true, :max_size_in_bytes => 1.gigabyte }
      },
      :lite => {
        :notification => { :enabled => true, :max_emails => 1_000 },
        :import_email => { :enabled => true, :import_frequency => 10.minutes },
        :api => { :enabled => true },
        :portal => { :enabled => true },
        :reporting => { :enabled => true,  :custom_reports_enabled => false },
        :storage_size => { :enabled => true, :max_size_in_bytes => 2.gigabyte }
      },
      :pro => {
        :notification => { :enabled => true, :max_emails => 10_000 },
        :import_email => { :enabled => true, :import_frequency => 1.minute },
        :api => { :enabled => true },
        :portal => { :enabled => true },
        :reporting => { :enabled => true,  :custom_reports_enabled => false },
        :storage_size => { :enabled => true, :max_size_in_bytes => 10.gigabytes }
      },
      :ent => {
        :notification => { :enabled => true, :max_emails => 100_000 },
        :import_email => { :enabled => true, :import_frequency => 10.minutes },
        :api => { :enabled => true },
        :portal => { :enabled => true },
        :reporting => { :enabled => true,  :custom_reports_enabled => false },
        :storage_size => { :enabled => true, :max_size_in_bytes => 100.gigabytes }
      },
      

    }
  end



  def initialize(edition_id)
    hash = self.class.definitions[edition_id]
    @notification = NotificationFeature.new(hash[:notification])
    @import_email = ImportEmailFeature.new(hash[:import_email])
    @api =          Feature.new(hash[:api])
    @portal =       Feature.new(hash[:portal])
    @reporting =    ReportingFeature.new(hash[:reporting]) 
    @storage_size = StorageSizeFeature.new(hash[:storage_size]) 
  end

  def self.init
    @@free = nil
    @@lite = nil
    @@pro  = nil
    @@ent  = nil
  end

  def self.all
    {
      :free => self.free,
      :lite => self.lite,
      :pro =>  self.pro,
      :ent =>  self.ent
    }
  end

  def self.free
    @@free ||= self.new :free
  end

  def self.lite
    @@lite ||= self.new :lite
  end

  def self.pro
    @@pro ||= self.new :pro
  end

  def self.ent
    @@ent ||= self.new :ent
  end


end


