require_relative '../command'
require_relative '../session'
require_relative '../appio'


class GrabToggle < Command
  def matches? line
    line.split == ["g"]
  end

  def process line, session
    session.on_list {|list| list.todo_grab_toggle }
  end

  def description
    CommandDesc.new("g", "toggle grab mode")
  end
end
