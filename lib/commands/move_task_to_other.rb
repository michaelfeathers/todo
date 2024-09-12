require_relative '../command'
require_relative '../session'
require_relative '../appio'


class MoveTaskToOther < Command
  def matches? line
    line.split == ["-"]
  end

  def process line, session
    session.move_task_to_other
  end

  def description
    CommandDesc.new("-", "move task to other list")
  end
end
