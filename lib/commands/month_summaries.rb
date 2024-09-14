require_relative '../command'
require_relative '../session'
require_relative '../appio'


class MonthSummaries < Command
  def matches? line
    (line.split in ["m", *args]) && args.count <= 1
  end

  def process line, session
    session.on_list do |list|
      tokens = line.split
      case tokens.count
      when 1
        list.todo_month_summaries
      when 2
        list.todo_month_summaries(tokens[1].to_i)
      end
    end
  end

  def description
    CommandDesc.new("m", "show month summaries")
  end
end
