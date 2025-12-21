require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Retag < Command
  def matches? line
    (line.split in ["rt", *args]) && args.count == 1
  end

  def process line, session
    session.on_list {|list| list.retag(line.split[1]) }
  end

  def description
    CommandDesc.new("tr tag", "re-tag the task at the cursor with tag. Tag if not tagged")
  end
end