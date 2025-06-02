require_relative '../command'
require_relative '../session'
require_relative '../appio'
require 'gruff'

class TrendChart < Command
  def matches? line
    (line.split in ["tc", *args]) && args.count <= 1
  end

  def process line, session
    opt_year = line.split[1] if line.split.count == 2
    session.on_list {|list| list.todo_trend_chart(opt_year) }
  end

  def description
    CommandDesc.new("tc", "show trend chart")
  end
end