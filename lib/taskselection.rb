$:.unshift File.dirname(__FILE__)

require 'day'
require 'appio'


def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end


class TaskSelection

  def initialize descs 
    @descs = descs
  end

  def L
    TaskSelection.new(@descs.select{|d| d[1] == "L" })
  end

  def R
    TaskSelection.new(@descs.select{|d| d[1] == "R" })
  end

  def year year
    TaskSelection.new(@descs.select {|d| d.first.year.to_i == year })
  end

  def month month
    TaskSelection.new(@descs.select {|d| d.first.month_no.to_i == month })
  end

  def day day
    TaskSelecton.new(@descs.select {|d| d.first.day == day })
  end


  def count
    @descs.count
  end
end
