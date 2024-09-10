require_relative '../command'
require_relative '../session'
require_relative '../appio'


class GlobalFind < Command
  def matches? line
    (line.split in ["gf", *args]) && args.count == 1
  end

  def process line, session
    session.global_find(line.split[1])
  end

  def description
    CommandDesc.new("gf text", "find text across all task lists")
  end
end
