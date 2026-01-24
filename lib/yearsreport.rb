require_relative 'day'
require_relative 'taskdesc'
require_relative 'appio'
require_relative 'summary_columns'


class YearsReport

  def initialize io, columns = SUMMARY_COLUMNS
    @io = io
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
    print_years_statistics
    print_total_statistics
  end

  def print_footer
    @io.append_to_console $/
  end

  def print_years_statistics
    years.each do |year|
      year_tasks = all_tasks.year(year)
      @io.append_to_console body_row(year.to_s, year_tasks)
    end

    @io.append_to_console $/
  end

  def print_total_statistics
    @io.append_to_console body_row("", all_tasks)

    @io.append_to_console $/
  end

  def read_task_descs
    @tasks ||= @io.read_archive
                  .lines
                  .map {|l| TaskDesc.from_line(l) }
  end

  def all_tasks
    TaskSelection.new(read_task_descs)
  end

  def years
    return [] if read_task_descs.empty?

    min_year = read_task_descs.map { |d| d.date.year_no }.min
    max_year = @io.today.year_no

    (min_year..max_year).to_a
  end

  def body_row(label, tasks)
    @format % ([label] + @columns.map { |_, calculator| calculator.call(tasks) })
  end

  def header_row
    @format % ([""] + @columns.map(&:first))
  end

end
