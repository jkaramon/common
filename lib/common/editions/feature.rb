
class Feature
  extend ActiveModel::Translation
  include ActionView::Helpers::NumberHelper
  attr_accessor :enabled
  attr_accessor :edition_id
  alias_method :enabled?, :enabled

  def disabled?
    !enabled
  end
  
  def constraints_info
    ""
  end

  def exceed_info
    ""
  end

  def disabled_info()
    loc(:disabled_info)
  end

  def edition_name
    "#{Edition.names[@edition_id]} edition"
  end

  def loc_info(params = {})
    params.merge!(:active_edition => edition_name)
    ::I18n.t(self.class.info_i18n_key, params)
  end

  def loc(key, params = {})
    puts Edition.names.inspect
    params.merge!(:active_edition => edition_name)
    ::I18n.t(self.class.i18n_key(key), params)
  end

  
  def self.type_name
    self.to_s.underscore
  end
  def self.info_i18n_key
    self.i18n_key :constraints_info
  end

   def self.i18n_key(key)
    "common.editions.#{type_name}.#{key}"
  end


  def initialize(edition_id, hash = {})
    @edition_id = edition_id
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

  def exceed_info
    loc(:exceed_info, :max_emails => max_emails_display_name)
  end
  
  
    

  def initialize(edition_id, hash = {})
    @max_emails = hash[:max_emails]
    super(edition_id, hash)
  end
end

class ImportEmailFeature < Feature
  attr_accessor :import_frequency

  def initialize(edition_id, hash = {})
    @import_frequency = hash[:import_frequency]
    super(edition_id, hash)
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

  def initialize(edition_id, hash = {})
    @custom_reports_enabled = hash[:custom_reports_enabled]
    @custom_reports_enabled = false if @custom_reports_enabled.nil?
    super(edition_id, hash)
  end

  def constraints_info
    return "" if !self.enabled? || self.custom_reports_enabled?
    loc_info
  end


end

class StorageSizeFeature < Feature
  attr_accessor :max_size_in_bytes

  def initialize(edition_id, hash = {})
    @max_size_in_bytes = hash[:max_size_in_bytes]
    super(edition_id, hash)
  end

  def size_display_name
    number_to_human_size(max_size_in_bytes, :precision => 0)
  end

  def constraints_info
    return "" unless self.enabled?
    loc_info(:max_size => size_display_name)
  end

  def exceed_info
    loc(:exceed_info, :max_size => size_display_name)
  end

  


end
