module GridList
  # reformats data to conform jqgrid json format.
  # total .. total pages 
  # page .. actual page number
  # records .. total records in the dataset
  # rows .. returned data
  def to_json(options={})
    settings = {}.merge(options)
    settings[:records] ||= self.count unless self.empty?
    settings[:total] = ( (settings[:records] - 1 ) / settings[:per_page] ) + 1
    "{ \"total\": \"#{settings[:total]}\", \"page\": \"#{settings[:page]}\", \"records\": \"#{settings[:records]}\",\"rows\": #{super(options)}}"
  end
end
