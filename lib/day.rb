$:.unshift File.dirname(__FILE__)

require 'date'


class Day
  attr_reader :month

  def self.from_text date_text
    self.new(DateTime.now)
  end

  def initialize date_text
    @month = "Dec"
  end

end
