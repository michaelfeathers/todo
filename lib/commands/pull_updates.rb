require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PullUpdates < Command
  def matches?(line)
    case line.split
    in ["pu"] then true
    in ["pu", position] then position =~ /\A\d+\z/
    else false
    end
  end

  def process(line, session)
    position = line.split[1]
    position ? pull_at(position.to_i, session) : pull_next_day(session)
  end

  def description
    CommandDesc.new("pu [n]", "pull next day's updates (or the update at position n) to foreground list")
  end

  private

  def pull_next_day(session)
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

  def pull_at(position, session)
    io = session.foreground_tasks.io
    updates = io.read_updates.lines.to_a
    return unless (1..updates.count).include?(position)

    update = updates.delete_at(position - 1)
    task = update.split(' ', 2).last.chomp

    session.foreground_tasks.add(task)
    io.write_updates(updates)
  end
end
