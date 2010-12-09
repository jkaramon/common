module TimeExtensions

    def is_lower(time)
      self.minutes_low < time.minutes_low
    end

    def is_lower_high(time)
      self.minutes_low < time.minutes_high
    end

    def diference_from(time)
      self.minutes_high - time.minutes_low
    end

    def minutes_low()
      self.hour*60 + self.min
    end

    def minutes_high()
      ret = self.hour*60 + self.min
      if ret == 0
        ret = 24*60
      end
      ret
    end
    
end

class Time
  include TimeExtensions
end

class ActiveSupport::TimeWithZone
  include TimeExtensions
end
