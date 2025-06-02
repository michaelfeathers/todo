require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Trend < Command
  def matches? line
    line.split == ["tr"]
  end

  def process line, session
    session.on_list {|list| list.todo_trend }
  end

  def description
    CommandDesc.new("tr", "show trend")
  end
end