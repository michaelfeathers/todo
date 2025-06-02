require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Today < Command
  def matches? line
    (line.split in ["t", *args]) && args.count <= 1
  end

  def process line, session
    session.on_list {|list| list.todo_today(line.split.count == 1 ? 0 : line.split[1]) }
  end

  def description
    CommandDesc.new("t  [n]", "show tasks n days prev. If no arg, defaults to today")
  end
end