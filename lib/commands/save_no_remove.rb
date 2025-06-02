require_relative '../command'
require_relative '../session'
require_relative '../appio'

class SaveNoRemove < Command
  def matches? line
    line.split == ["ss"]
  end

  def process line, session
    session.on_list {|list| list.todo_save_no_remove }
  end

  def description
    CommandDesc.new("ss", "save task at cursor without removing")
  end
end