require_relative '../command'
require_relative '../session'

class CursorToStart < Command
  def matches?(line)
    line.split == ["cc"]
  end

  def process(line, session)
    session.list.cursor_set(0)
  end

  def description
    CommandDesc.new("cc", "move cursor to the 0th task")
  end

end
