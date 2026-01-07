require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PullUpdates < Command
  def matches?(line)
    line.split == ["pu"]
  end

  def process(line, session)
    io = session.foreground_tasks.io
    updates = io.read_updates.lines.to_a
    return if updates.empty?

    next_date = updates.map { |u| u.split.first }.min
    next_day_updates, remaining_updates = updates.partition do |update|
      update.split.first == next_date
    end

    session.foreground_tasks.add("")

    next_day_updates.reverse.each do |update|
      task = update.split(' ', 2).last.chomp
      session.foreground_tasks.add(task)
    end

    io.write_updates(remaining_updates)
  end

  def description
    CommandDesc.new("pu", "pull next day's updates to foreground list")
  end
end
