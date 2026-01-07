require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PullUpdates < Command
  def matches?(line)
    line.split == ["pu"]
  end

  def process(line, session)
    io = session.foreground_tasks.io
    tomorrow = io.today.with_more_days(1).to_s

    updates = io.read_updates.lines.to_a
    tomorrow_updates, remaining_updates = updates.partition do |update|
      update.split.first == tomorrow
    end

    tomorrow_updates.reverse.each do |update|
      task = update.split(' ', 2).last.chomp
      session.foreground_tasks.add(task)
    end

    io.write_updates(remaining_updates)
  end

  def description
    CommandDesc.new("pu", "pull tomorrow's updates to foreground list")
  end
end
