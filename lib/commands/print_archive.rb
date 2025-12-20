require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PrintArchive < Command
  def matches?(line)
    line.split == ["pa"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      formatted_archive = format_archive_with_date_toggle(io.read_archive)
      io.display_paginated(formatted_archive)
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("pa", "print the archive")
  end

  private

  def format_archive_with_date_toggle(content)
    lines = content.lines
    return content if lines.empty?

    formatted_lines = []
    last_date = nil
    use_reverse = false

    lines.each do |line|
      # Extract the date (first word) from the line
      parts = line.split(' ', 2)
      next if parts.empty?

      date = parts[0]
      rest = parts[1] || ""

      # Toggle reverse video when date changes
      if date != last_date
        last_date = date
        use_reverse = !use_reverse
      end

      # Apply formatting to the date only
      if use_reverse
        formatted_lines << "\e[7m#{date}\e[0m #{rest}"
      else
        formatted_lines << "#{date} #{rest}"
      end
    end

    formatted_lines.join
  end
end