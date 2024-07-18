require_relative '../command'
require_relative '../session'


class DisplayEdit < Command
  def matches?(line)
    line.strip == "ed"
  end

  def process(line, session)
    session.list.todo_display_edit
  end

  def description
    CommandDesc.new("ed", "display the task at the cursor with numbered columns")
  end

end
