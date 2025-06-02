require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Surface < Command
  def matches? line
    (line.split in ["su", *args]) && args.count <= 1
  end

  def process line, session
    count_items = line.split.count > 1 ? line.split[1].to_i : 1
    session.surface(count_items)
  end

  def description
    CommandDesc.new("su", "surface the last task by putting it first")
  end
end