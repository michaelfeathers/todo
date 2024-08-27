
require_relative '../command'
require_relative '../session'

class Edit < Command

  def description
    CommandDesc.new("e  text", "edit task at cursor, replacing it with text")
  end

  def matches? line
    (line.split in ["e", *args]) && args.count >= 1
  end

  def process line, session
    session.list.todo_edit(line.split.drop(1).join(" "))
  end

end
