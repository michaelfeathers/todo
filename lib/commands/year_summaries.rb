require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../yearsreport'


class YearSummaries < Command
  def matches? line
    line.strip == "y"
  end

  def process line, session
    session.on_list do |list|
      io = list.io

      YearsReport.new(io).run
    end
  end

  def description
    CommandDesc.new("y", "show year summaries")
  end
end
