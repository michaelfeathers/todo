require_relative '../command'
require_relative '../session'


class CursorToStart < Command

  def description
    CommandDesc.new("cc", "move cursor to the 0th task")
  end

  def matches?(line)
    line.split == ["cc"]
  end

  def process(line, session)
    session.on_list {|list| list.cursor_set(0) }
  end

end
