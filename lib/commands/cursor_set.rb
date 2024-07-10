require_relative '../command'
require_relative '../session'


class CursorSet < Command

  def description
    CommandDesc.new("c  n", "set cursor position to line n")
  end

  def matches? line
    line.split.count == 2 && line.split[0] == "c"
  end

  def process line, session
    session.list.cursor_set(line.split[1].to_i)
  end

end
