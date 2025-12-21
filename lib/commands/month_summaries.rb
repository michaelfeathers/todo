require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../monthsreport'


class MonthSummaries < Command
  def matches? line
    (line.split in ["m", *args]) && args.count <= 1
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      year = line.split[1].to_i if line.split.size > 1
      year ||= io.today.year_no

      MonthsReport.new(io, year).run
    end
  end

  def description
    CommandDesc.new("m", "show month summaries")
  end
end
