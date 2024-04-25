$:.unshift File.dirname(__FILE__)

require 'day'
require 'appio'


def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end


class MonthsReport

  FORMAT = "%-5s %10s %10s %10s %10s\n" 

  def initialize io, year
    @io = io
    @year = year
  end

  def run 
    task_descs = read_task_descs
    year_tasks = TaskSelection.new(task_descs).year(@year)
    today_tasks = TaskSelection.new(task_descs).date(@io.today)

    columns = [["R7K",   ->(tasks) { tasks.R.count } ],
               ["Life",  ->(tasks) { tasks.L.count } ],
               ["Total", ->(tasks) { tasks.count } ],
               ["R7K %", ->(tasks) { tasks.R.percent_of(tasks) } ]]


    print_header                columns
    print_months_statistics     columns, year_tasks
    print_year_statistics       columns, year_tasks
    print_today_statistics      columns, today_tasks


    @io.append_to_console $/
    @io.get_from_console
  end

  def print_header columns
    @io.append_to_console "\n\n"
    @io.append_to_console column_names_row("", columns)

    @io.append_to_console $/
  end

  def print_months_statistics columns, year_tasks
    (1..12).each do |month|
      month_tasks = year_tasks.month(month)

      @io.append_to_console row(month_name_of(month), columns, month_tasks)
    end

    @io.append_to_console $/
  end

  def print_today_statistics columns, today_tasks
    if today_tasks.count > 0 && @year == @io.today.year_no
      @io.append_to_console row("Today", columns, today_tasks)
    end

    @io.append_to_console $/
  end

  def print_year_statistics columns, year_tasks
    @io.append_to_console row("", columns, year_tasks)
    @io.append_to_console $/
  end

  def read_task_descs
      @io.read_archive
         .lines
         .map {|l| [Day.from_text(l.split[0]), l.split[1].chars.first] }
  end

  def row label, columns, tasks
    FORMAT % [label].concat(columns.map { |c| c[1].call(tasks) })
  end

  def column_names_row label, columns
    FORMAT % [label].concat(columns.map { |c| c.first })
  end

end
