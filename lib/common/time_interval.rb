class TimeInterval

  def initialize(time_from, time_to)
    @time_from = time_from
    @time_to = time_to
  end

  def from
    @time_from
  end

  def to
    @time_to
  end

  def overlaps?(interval)
    (@time_from >= interval.from && @time_from <= interval.to) || 
    (@time_to >= interval.from && @time_to <= interval.to) ||
    (@time_from <= interval.from && @time_to >= interval.to)
  end

  def merge(interval)
    @time_from = interval.from if @time_from > interval.from
    @time_to = interval.to if @time_to < interval.to
  end

  def intersect(interval)
    @time_from = interval.from if @time_from < interval.from
    @time_to = interval.to if @time_to > interval.to
    self
  end

end

class TimeIntervalArray
  
  def initialize
    @data = []
  end

  def add( interval )
    added = false
    @data.count.times do |i|
      if @data[i].overlaps?(interval)
        # if overlaps, merge intervals
        @data[i].merge(interval)
        if (i + 1 < @data.count) && @data[i].overlaps?(@data[i+1])
          # test also next interval if exists
          @data[i].merge(@data[i+1])
          @data.delete_at(i+1)
        end
        added = true
        break
      end
      if @data[i].from > interval.to
        # insert before current item if not overlaps
        @data.insert(i, interval)
        added = true
        break
      end
    end
    # append if the item is last
    @data << interval if !added
  end

  def intersect( interval )
    new_data = []
    @data.each do |item|
      if item.overlaps? interval
        new_data << item.intersect(interval)
      end
    end
    @data = new_data
    self
  end

  def merge( interval_array )
    return self if interval_array.blank?
    interval_array.items.each do |interval|
      self.add(interval)
    end
    self
  end

  def items
    @data    
  end

  def blank?
    @data.blank?
  end

end
