require_relative 'day'
require_relative 'appio'


class TaskSelection

  def initialize descs
    @descs = descs
  end

  def L
    TaskSelection.new(@descs.select{|d| d.task_type == "L" })
  end

  def R
    TaskSelection.new(@descs.select{|d| d.task_type == "R" })
  end

  def W
    TaskSelection.new(@descs.select{|d| d.task_type == "W" })
  end

  def year year
    TaskSelection.new(@descs.select {|d| d.date.year.to_i == year })
  end

  def month month
    TaskSelection.new(@descs.select {|d| d.date.month_no.to_i == month })
  end

  def date date
    TaskSelection.new(@descs.select {|d| d.date === date })
  end

  def percent_of other_tasks
    return 0 if other_tasks.count == 0

    other_total = count
    all_total   = other_tasks.count

    (100.0 * other_total / all_total).to_i
  end

  def adjusted_count
    win_multiplier = 5
    count + (win_multiplier - 1) * @descs.select {|d| d.task_type == "W"}.count
  end

  def count
    @descs.count
  end
end
