$:.unshift File.dirname(__FILE__)

require 'date'


class Day

  def self.from_text date_text
    self.new(DateTime.parse(date_text))
  end

  def initialize date
    @date = DateTime.new(date.year, date.month, date.day, 0, 0, 0, date.zone)
  end

  def month
    @date.strftime("%b")
  end
  
  def day
    @date.strftime("%d")
  end

  def year
    @date.strftime("%y")
  end

end
