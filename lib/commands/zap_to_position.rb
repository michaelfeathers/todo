require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ZapToPosition < Command
  def matches? line
    (line.split in ["z", *args]) && args.count == 1
  end

  def process line, session
    session.on_list {|list| list.todo_zap_to_position(line.split[1].to_i) }
  end

  def description
    CommandDesc.new("z  n", "move (zap) task at cursor to line n")
  end
end