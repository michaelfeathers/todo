require_relative '../command'
require_relative '../session'
require_relative '../appio'
require 'date'

class Push < Command
  def matches? line
    (line.split in ["p", *args]) && args.count == 1
  end

  def process line, session
    days_text = line.split[1]

    session.on_list do |list|
      return if list.count < 1

      io = list.io
      updates = io.read_updates.lines.to_a
      date_text = io.today.with_more_days(days_text.to_i).to_s

      updates << [date_text, list.task_at_cursor + "\n"].join(' ')
      updates = updates.sort_by {|line| DateTime.parse(line.split.first) }

      io.write_updates(updates)
      list.remove_task_at_cursor
      list.save_all
    end
  end

  def description
    CommandDesc.new("p  n", "push task at cursor forward n number of days")
  end
end