require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Save < Command
  def matches? line
    line.split == ["s"]
  end

  def process line, session
    session.on_list {|list| list.todo_save }
  end

  def description
    CommandDesc.new("s", "save task at cursor")
  end
end