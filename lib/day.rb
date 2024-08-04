require 'date'


class Day

  def self.from_text date_text
    self.new(DateTime.parse(date_text))
  end

  def self.today
    self.new(DateTime.now)
  end

  def with_more_days days
    Day.new(@date.next_day(days))
  end

  def with_fewer_days days
    Day.new(@date.prev_day(days))
  end

  def initialize date
    @date = DateTime.new(date.year, date.month, date.day, 0, 0, 0, date.zone)
  end

  def === other
    @date === other.date
  end

  def == other
    @date == other.date
  end

  def month
    @date.strftime("%b")
  end

  def month_no
    @date.month
  end

  def day
    @date.strftime("%d")
  end

  def year
    @date.strftime("%Y")
  end

  def year_no
    @date.year
  end

  def date
    @date
  end

  def to_s
    @date.to_s[0, 10]
  end
end
