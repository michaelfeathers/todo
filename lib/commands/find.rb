require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Find < Command
  def matches? line
    (line.split in ["f", *args]) && args.count >= 1
  end

  def process line, session
    limit = line.split.count == 3 ? line.split[2].to_i : nil
    session.on_list {|list| list.todo_find(line.split[1], limit) }
  end

  def description
    CommandDesc.new("f  text [n]", "find all (or [n]) tasks containing specified text")
  end
end
