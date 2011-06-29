module GridList
  # reformats data to conform jqgrid json format.
  # total .. total pages 
  # page .. actual page number
  # records .. total records in the dataset
  # rows .. returned data
  def to_json(options={})
    settings = {}.merge(options)
    query = {}.merge(options)
    settings[:records] ||= 0
    settings[:total] = ( (settings[:records] - 1 ) / settings[:per_page] ) + 1
    
    self.each do |entity|
      time_to_local(entity) 
    end

    "{ \"total\": \"#{settings[:total]}\", \"page\": \"#{settings[:page]}\", \"records\": \"#{settings[:records]}\",\"rows\": #{super(options)}}"
  end

  # Iterates all time attributes and converts them from UTC to local time
  def time_to_local(entity)
    return unless entity.respond_to?(:each)
    entity.each do |key, value| 
      entity[key] = Time.zone.at(value).to_s if value.is_a?(Time) 
    end
  end

  module_function :time_to_local
  

end
