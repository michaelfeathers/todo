require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ShowUpdates < Command
  def matches? line
    line.split == ["pp"]
  end

  def process line, session
    session.on_list {|list| list.todo_show_updates }
  end

  def description
    CommandDesc.new("pp", "show updates")
  end
end