require_relative '../command'
require_relative '../session'


class CursorToEnd < Command

  def description
    CommandDesc.new("ce", "move cursor to the last task")
  end

  def matches?(line)
    line.split == ["ce"]
  end

  def process(line, session)
    session.on_list {|list| list.cursor_set(list.count - 1) }
  end

end
