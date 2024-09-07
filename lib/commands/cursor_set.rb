require_relative '../command'
require_relative '../session'


class CursorSet < Command

  def description
    CommandDesc.new("c  n", "set cursor position to line n")
  end

  def matches? line
    (line.split in ["c", *args]) && args.count == 1
  end

  def process line, session
    session.on_list do |list|
      list.cursor_set(line.split[1].to_i)
    end
  end

end
