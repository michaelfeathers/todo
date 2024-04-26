$:.unshift File.dirname(__FILE__)


class TaskDesc

  attr_reader :date, :task_type

  def initialize date, task_type
    @date = date
    @task_type = task_type
  end

end
