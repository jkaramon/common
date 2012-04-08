class Edition
  attr_accessor :id
  attr_accessor :level
  attr_accessor :price_per_month
  attr_accessor :features 



  def abbreviation
    self.class.abbreviations[self.id]
  end

  def price_per_month_formatted
    self.price_per_month.format(:no_cents => true)
  end

  def name
    self.class.names[self.id]
  end

  def self.abbreviations
    ::I18n.t("common.editions.edition.abbreviations")
  end

  def self.names
    ::I18n.t("common.editions.edition.names") 
  end

  def initialize(hash = {})
    @id = hash[:id]
    @level = hash[:level]
    @price_per_month = Money.new(hash[:price] * 100, 'USD')
    @features = FeatureSet.all[@id]
  end


  def self.to_mongo(value)
    if value.nil? || value == ''
      nil
    else
      edition = value.is_a?(Edition) ? value : Edition.find(value.to_s)
      edition.try(:id)
    end
  end

  def self.from_mongo(value)
    if value.blank? || value.is_a?(Edition)
      value
    else
      Edition.find(value)
    end
  end
  
  def blank?
    id.nil?
  end
  
  def ==(other)
     other.is_a?(self.class) && self.id == other.id
   end

   def eql?(other)
     self == other
   end

   def equal?(other)
     object_id === other.object_id
   end

   def hash
     id.hash
   end
  


  def self.init
    @@free = nil
    @@lite = nil
    @@pro  = nil
    @@ent  = nil
  end

  def self.find(id)
    self.all[id]
  end

 
  def self.all
    HashWithIndifferentAccess.new({
      :free => self.free,
      :lite => self.lite,
      :pro =>  self.pro,
      :ent =>  self.ent
    })
  end


  def self.free
    @@free ||= self.new(:id => :free, :level => 0, :price => 0)
  end

  def self.lite
    @@lite ||= self.new(:id => :lite, :level => 1, :price => 29)
  end

  def self.pro
    @@pro ||= self.new(:id => :pro, :level => 2, :price => 119)
  end

  def self.ent
    @@ent ||= self.new(:id => :ent, :level => 3, :price => 199)
  end

end


