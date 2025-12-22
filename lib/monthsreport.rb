require_relative 'day'
require_relative 'taskdesc'
require_relative 'appio'


MONTH_NAMES = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].freeze

def month_name_of(month_no)
  MONTH_NAMES[month_no - 1] || ''
end


class MonthsReport

  COLUMNS = [
             ["Life",  ->(tasks) { tasks.L.count } ],
             ["Work",  ->(tasks) { tasks.R.count + tasks.D.count } ],
             ["DRD",   ->(tasks) { tasks.D.count } ],
             ["W %",   ->(tasks) { tasks.R.percent_of(tasks) + tasks.D.percent_of(tasks)} ],
             ["Total", ->(tasks) { tasks.count } ]
            ]


  def initialize io, year, columns = COLUMNS
    @io = io
    @year = year
    @columns = columns
    @tasks = nil

    @format = "%-5s" + @columns.size.times.map { " %10s" }.join + $/
  end

  def run
    print_header
    print_body
    print_footer

    @io.get_from_console
  end

  def print_header
    @io.append_to_console $/ + $/
    @io.append_to_console header_row

    @io.append_to_console $/
  end

  def print_body
    print_months_statistics
    print_year_statistics
    print_today_statistics
  end

  def print_footer
    @io.append_to_console $/
  end

  def print_months_statistics
    (1..12).each do |month|
      month_tasks = year_tasks.month(month)
      @io.append_to_console body_row(month_name_of(month), month_tasks)
    end

    @io.append_to_console $/
  end

  def print_today_statistics
    if today_tasks.count > 0 && @year == @io.today.year_no
      @io.append_to_console body_row("Today", today_tasks)
    end

    @io.append_to_console $/
  end

  def print_year_statistics
    @io.append_to_console body_row("", year_tasks)

    @io.append_to_console $/
  end

  def read_task_descs
    @tasks ||= @io.read_archive
                  .lines
                  .map {|l| TaskDesc.from_line(l) }
  end

  def year_tasks
    TaskSelection.new(read_task_descs).year(@year)
  end

  def today_tasks
    TaskSelection.new(read_task_descs).date(@io.today)
  end

  def body_row(label, tasks)
    @format % ([label] + @columns.map { |_, calculator| calculator.call(tasks) })
  end

  def header_row
    @format % ([""] + @columns.map(&:first))
  end

end
