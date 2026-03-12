require_relative '../command'
require_relative '../session'
require_relative '../appio'

class FindInArchive < Command
  def matches? line
    (line.split in ["fa", *args]) && args.count >= 1
  end

  def process line, session
    search_text = line.split[1]

    session.on_list do |list|
      io = list.io
      archive_lines = io.read_archive.lines
      found = archive_lines.grep(/#{Regexp.escape search_text}/i)

      output = "Archive matches for '#{search_text}':\n\n"
      output += "#{found.join}#{$/}#{found.count} found#{$/}"

      io.display_paginated(output)
      io.get_from_console unless io.headless?
    end
  end

  def description
    CommandDesc.new("fa text", "find all archive entries containing specified text")
  end
end
