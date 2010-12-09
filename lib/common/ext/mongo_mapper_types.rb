module ActiveSupport
  class TimeZone
    def self.to_mongo(value)
      if value.nil? || value == ''
        nil
      else
        time_zone = value.is_a?(TimeZone) ? value : TimeZone[value.to_s]
        time_zone.name
      end
    end

    def self.from_mongo(value)
      if value.blank? || value.is_a?(TimeZone)
        value
      else
        TimeZone[value]
      end
    end
  end
end

class Money
  def self.to_mongo(money)
    return nil if money.nil?
    #raise "Invalid type of money : #{money}" if money.class != Money
    return money if money.class == String
    return "#{money.cents} #{money.currency.iso_code}" if money.class == Money
  end
  def self.from_mongo(money)
    return nil if money.nil?
    return money if money.class == Money
    raise "Invalid money value #{money}" if money.class != String
    money_data = money.split
    Money.new(money_data[0].to_i, money_data[1])
  end
end
