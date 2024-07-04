$:.unshift File.dirname(__FILE__)


class TaskDesc

  attr_reader :date, :task_type

  def self.from_line line
    date_text, type_text = line.split

    TaskDesc.new(Day.from_text(date_text),
                 type_text.chars.first)
  end

  def initialize date, task_type
    @date = date
    @task_type = task_type
  end

end
