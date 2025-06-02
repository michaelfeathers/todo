require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ZapToTop < Command
  def matches?(line)
    line.split == ["zz"]
  end

  def process(line, session)
    session.on_list {|list| list.todo_zap_to_top }
  end

  def description
    CommandDesc.new("zz", "move the task at the cursor to the top (position 0)")
  end
end