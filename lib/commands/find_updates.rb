require_relative '../command'
require_relative '../session'
require_relative '../appio'

class FindUpdates < Command
  def matches? line
    (line.split in ["fu", *args]) && args.count >= 1
  end

  def process line, session
    limit = line.split.count == 3 ? line.split[2].to_i : nil
    search_text = line.split[1]

    io = session.list.io

    updates = io.read_updates.lines
    found_updates = updates.each_with_index
      .select { |update, _| update =~ /#{Regexp.escape search_text}/i }
      .map { |update, index| "%4s %s" % [index + 1, update] }
    found_updates_to_report = limit ? found_updates.take(limit) : found_updates

    output = "Updates:\n\n"
    output += "#{found_updates_to_report.join}#{$/}#{found_updates_to_report.count}#{$/}#{$/}"

    io.display_paginated(output)
    io.get_from_console
  end

  def description
    CommandDesc.new("fu text [n]", "find all (or [n]) updates containing specified text, prefixed with position number")
  end
end
