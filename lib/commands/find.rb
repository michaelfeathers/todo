require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Find < Command
  def matches? line
    (line.split in ["f", *args]) && args.count >= 1
  end

  def process line, session
    limit = line.split.count == 3 ? line.split[2].to_i : nil
    search_text = line.split[1]

    io = session.list.io

    # Find tasks in current task list
    found_tasks = session.list.find(search_text)
    found_tasks_to_report = limit ? found_tasks.take(limit) : found_tasks

    # Find tasks in updates file
    updates = io.read_updates.lines
    found_updates = updates.grep(/#{Regexp.escape search_text}/i)
    found_updates_to_report = limit ? found_updates.take(limit) : found_updates

    # Build the complete output
    output = "Tasks:\n\n"
    output += "#{found_tasks_to_report.join}#{$/}#{found_tasks_to_report.count}#{$/}#{$/}"
    output += "#{$/}"
    output += "Updates:\n\n"
    output += "#{found_updates_to_report.join}#{$/}#{found_updates_to_report.count}#{$/}#{$/}"

    # Display with pagination
    io.display_paginated(output)
    io.get_from_console
  end

  def description
    CommandDesc.new("f  text [n]", "find all (or [n]) tasks containing specified text in tasks and updates")
  end
end
