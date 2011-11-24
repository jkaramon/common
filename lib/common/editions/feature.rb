class Feature
  extend ActiveModel::Translation
  include ActionView::Helpers::NumberHelper
  attr_accessor :enabled
  alias_method :enabled?, :enabled

  def disabled?
    !enabled
  end
  
  def constraints_info
    ""
  end
  def loc_info(params = {})
    ::I18n.t(self.class.info_i18n_key, params)
  end
  
  def self.type_name
    self.to_s.underscore
  end
  def self.info_i18n_key
    "common.editions.#{type_name}.constraints_info"
  end

  def initialize(hash = {})
    @enabled = hash[:enabled]
    @enabled = false if @enabled.nil?
  end
end

class NotificationFeature < Feature
  attr_accessor :max_emails

  def max_emails_display_name
    number_with_delimiter(max_emails)
  end

  def constraints_info
    return "" unless self.enabled?
    loc_info(:max_emails => max_emails_display_name)
  end
    

  def initialize(hash = {})
    @max_emails = hash[:max_emails]
    super(hash)
  end
end

class ImportEmailFeature < Feature
  attr_accessor :import_frequency

  def initialize(hash = {})
    @import_frequency = hash[:import_frequency]
    super(hash)
  end

  def import_frequency_in_minutes
    import_frequency / 60
  end
  
  def constraints_info
    return "" unless self.enabled?
    return "real-time"  if import_frequency_in_minutes < 2 
    loc_info(:import_frequency => import_frequency_in_minutes)
  end

end

class ReportingFeature < Feature
  attr_accessor :custom_reports_enabled
  alias_method :custom_reports_enabled?, :custom_reports_enabled

  def initialize(hash = {})
    @custom_reports_enabled = hash[:custom_reports_enabled]
    @custom_reports_enabled = false if @custom_reports_enabled.nil?
    super(hash)
  end

  def constraints_info
    return "" if !self.enabled? || self.custom_reports_enabled?
    loc_info
  end


end

class StorageSizeFeature < Feature
  attr_accessor :max_size_in_bytes

  def initialize(hash = {})
    @max_size_in_bytes = hash[:max_size_in_bytes]
    super(hash)
  end

  def import_frequency_display_name
    number_to_human_size(max_size_in_bytes, :precision => 0)
  end

  def constraints_info
    return "" unless self.enabled?
    loc_info(:max_size_in_bytes => import_frequency_display_name)
  end


end
