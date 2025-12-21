require_relative 'day'
require_relative 'appio'


class TaskSelection

  def initialize descs
    @descs = descs
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
    other_total = count
    all_total   = other_tasks.count

    all_total.zero? ? 0 : (100.0 * other_total / all_total).to_i
  end

  def count
    @descs.count
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.match?(/^[A-Z]$/) && args.empty? && !block_given?
      TaskSelection.new(@descs.select { |d| d.task_type == method_name.to_s })
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.match?(/^[A-Z]$/) || super
  end
end
