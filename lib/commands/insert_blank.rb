require_relative '../command'
require_relative '../session'
require_relative '../appio'


class InsertBlank < Command
  def matches?(line)
    line.split == ["i"]
  end

  def process(line, session)
    session.on_list {|list| list.todo_insert_blank }
  end

  def description
    CommandDesc.new("i", "insert a blank line at the cursor")
  end
end
