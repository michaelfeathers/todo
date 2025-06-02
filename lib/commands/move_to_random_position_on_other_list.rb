require_relative '../command'
require_relative '../session'
require_relative '../appio'

class MoveToRandomPositionOnOtherList < Command
  def matches?(line)
    line.split == ["_"]
  end

  def process(line, session)
    return if session.list.empty?
    session.move_task_to_random_position_on_other_list
  end

  def description
    CommandDesc.new("_", "move the task at the cursor to a random position on the other list")
  end
end