require_relative '../command'
require_relative '../session'
require_relative '../appio'

class TodayTargetFor < Command
  def matches? line
    (line.split in ["tf", *args]) && args.count == 1
  end

  def process line, session
    session.on_list {|list| list.todo_target_for(line.split[1].to_i) }
  end

  def description
    CommandDesc.new("tf n", "show how many more tasks are needed today to stay on track for n this month")
  end
end