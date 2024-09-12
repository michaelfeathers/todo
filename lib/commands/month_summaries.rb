require_relative '../command'
require_relative '../session'
require_relative '../appio'


class MonthSummaries < Command
  def matches? line
    (line.split in ["m", *args]) && args.count <= 1
  end

  def process line, session
    session.on_list do |list|
      list.todo_month_summaries                     if line.split.count == 1
      list.todo_month_summaries(line.split[1].to_i) if line.split.count == 2
    end
  end

  def description
    CommandDesc.new("m", "show month summaries")
  end
end
