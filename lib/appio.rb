ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/data/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATE_FILE  = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"
JUNK_FILE    = ROOT_DIR + "junk.txt"
LOG_FILE     = ROOT_DIR + "log.txt"
LOCK_FILE    = ROOT_DIR + "todo.lock"

class AppIo
  PAGE_SIZE = 40

  def display_paginated(content)
    lines = content.lines

    # If content is short, just display it normally
    if lines.count <= PAGE_SIZE
      clear_console
      append_to_console(content)
      return content
    end

    # Paginate for longer content
    page = 0
    total_pages = (lines.count.to_f / PAGE_SIZE).ceil

    loop do
      start_line = page * PAGE_SIZE
      end_line = [start_line + PAGE_SIZE, lines.count].min
      page_content = lines[start_line...end_line].join

      clear_console
      append_to_console(page_content)

      if end_line >= lines.count
        # Last page, just wait for any input
        break
      else
        # More pages available
        append_to_console($/ + ",,," + $/)
        input = get_from_console
        break if input && input.strip.downcase == 'q'
        page += 1
      end
    end

    content
  end

  def read_archive
    File.read(ARCHIVE_FILE)
  end

  def read_archive_for_display
    format_archive_with_date_toggle(File.read(ARCHIVE_FILE))
  end

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

  def write_archive archive_entries
    File.open(ARCHIVE_FILE, 'w') { |f| f.write(archive_entries.join) }
  end

  def append_to_archive line
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(line); }
  end

  def append_to_log line
    File.open(LOG_FILE, 'a') { |f| f.write(line); }
  end

  def read_log
    begin
      File.read(LOG_FILE)
    rescue => e
      ""
    end
  end

  def write_log text
    File.open(LOG_FILE, 'w') { |f| f.write(text + $/); }
  end

  def append_to_junk line
    File.open(JUNK_FILE, 'a') { |f| f.write(line); }
  end

  def read_tasks
    File.read(TODO_FILE)
  end

  def write_tasks tasks
    File.open(TODO_FILE, 'w') { |f| f.write(tasks.join) }
  end

  def read_updates
    File.read(UPDATE_FILE)
  end

  def write_updates updates
    File.open(UPDATE_FILE, 'w') { |f| f.write(updates.join) }
  end

  def append_to_console text
    print text
  end

  def get_from_console
    gets
  end

  def clear_console
    puts  "\e[H\e[2J"
  end

  def today
    Day.new(DateTime.now)
  end

  def renderer
    ConsoleRenderer.new
  end

end
