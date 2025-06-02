require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Push < Command
  def matches? line
    (line.split in ["p", *args]) && args.count == 1
  end

  def process line, session
    session.on_list {|list| list.todo_push(line.split[1]) }
  end

  def description
    CommandDesc.new("p  n", "push task at cursor forward n number of days")
  end
end