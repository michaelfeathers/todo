$:.unshift File.dirname(__FILE__)

require 'day'
require 'taskdesc'
require 'appio'


def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end


class MonthsReport

  
  COLUMNS = [["R7K",   ->(tasks) { tasks.R.count } ],
             ["Life",  ->(tasks) { tasks.L.count } ],
             ["Total", ->(tasks) { tasks.count } ]]
             #["R7K %", ->(tasks) { tasks.R.percent_of(tasks) } ]]



  def initialize io, year
    @io = io
    @year = year

    @format = "%-5s" + COLUMNS.size.times.map { " %10s" }.join + "\n"
  end

  def run 
    task_descs = read_task_descs
    year_tasks = TaskSelection.new(task_descs).year(@year)
    today_tasks = TaskSelection.new(task_descs).date(@io.today)

    print_header                
    print_months_statistics     year_tasks
    print_year_statistics       year_tasks
    print_today_statistics      today_tasks


    @io.append_to_console $/
    @io.get_from_console
  end

  def print_header 
    @io.append_to_console "\n\n"
    @io.append_to_console column_names_row("", COLUMNS)

    @io.append_to_console $/
  end

  def print_months_statistics year_tasks
    (1..12).each do |month|
      month_tasks = year_tasks.month(month)

      @io.append_to_console row(month_name_of(month), COLUMNS, month_tasks)
    end

    @io.append_to_console $/
  end

  def print_today_statistics today_tasks
    if today_tasks.count > 0 && @year == @io.today.year_no
      @io.append_to_console row("Today", COLUMNS, today_tasks)
    end

    @io.append_to_console $/
  end

  def print_year_statistics year_tasks
    @io.append_to_console row("", COLUMNS, year_tasks)
    @io.append_to_console $/
  end

  def read_task_descs
    @io.read_archive
       .lines
       .map {|l| TaskDesc.new(Day.from_text(l.split[0]), l.split[1].chars.first) }
  end

  def row label, columns, tasks
    @format % [label].concat(columns.map { |c| c[1].call(tasks) })
  end

  def column_names_row label, columns
    @format % [label].concat(columns.map { |c| c.first })
  end

end
