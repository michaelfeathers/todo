require_relative '../command'
require_relative '../session'
require_relative '../appio'


class MonthSummaries < Command
  def matches? line
    (line.split in ["m", *args]) && args.count <= 1
  end

  def process line, session
    session.on_list do |list|
      month = line.split[1].to_i if line.split.size > 1
      list.todo_month_summaries(month)
    end
  end

  def description
    CommandDesc.new("m", "show month summaries")
  end
end
