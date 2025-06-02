require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Remove < Command
  def matches? line
    line.split == ["r"]
  end

  def process line, session
    session.on_list {|list| list.todo_remove }
  end

  def description
    CommandDesc.new("r", "remove task at cursor")
  end
end