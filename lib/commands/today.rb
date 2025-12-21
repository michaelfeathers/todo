require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../day'

class Today < Command
  def matches? line
    (line.split in ["t", *args]) && args.count <= 1
  end

  def process line, session
    days_prev = line.split.count == 1 ? 0 : line.split[1]

    session.on_list do |list|
      io = list.io
      day_to_display = io.today.with_fewer_days(days_prev.to_i)
      found = io.read_archive
                 .lines
                 .select {|line| Day.from_text(line.split.first) === day_to_display }

      io.append_to_console($/)
      found.each {|line| io.append_to_console(line) }
      io.append_to_console($/ + "#{found.count}" + $/ + $/)
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("t  [n]", "show tasks n days prev. If no arg, defaults to today")
  end
end