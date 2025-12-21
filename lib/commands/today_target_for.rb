require_relative '../command'
require_relative '../session'
require_relative '../appio'
require 'date'

class TodayTargetFor < Command
  def matches? line
    (line.split in ["tf", *args]) && args.count == 1
  end

  def process line, session
    month_target = line.split[1].to_i

    session.on_list do |list|
      io = list.io
      today = io.today.date
      dates = io.read_archive
                 .lines
                 .reject {|l| l.strip.empty? }
                 .map {|l| DateTime.parse(l.split[0]) }

      current_month_dates = dates.select {|date| date.month == today.month && date.year == today.year }
      tasks_done_so_far   = current_month_dates.count

      last_day_of_month = Date.new(today.year, today.month, -1)
      remaining_days    = (today..last_day_of_month).count
      remaining_tasks   = [month_target - tasks_done_so_far, 0].max

      tasks_per_day = remaining_days > 0 ? (remaining_tasks.to_f / remaining_days).ceil : 0

      days_passed = today.day - 1
      daily_average = days_passed > 0 ? (tasks_done_so_far.to_f / days_passed).round(1) : 0.0

      io.append_to_console "\n\n    Do %d per day to meet monthly goal of %d\n\n    Daily average so far: %.1f\n\n" % [tasks_per_day, month_target, daily_average]
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("tf n", "show how many more tasks are needed today to stay on track for n this month")
  end
end