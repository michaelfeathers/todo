$:.unshift File.dirname(__FILE__)

require 'date'


class Day
  attr_reader :month

  def initialize date_text
    @month = "Dec"
  end

end
