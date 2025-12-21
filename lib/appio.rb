require 'readline'

ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/data/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATE_FILE  = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"
JUNK_FILE    = ROOT_DIR + "junk.txt"
LOG_FILE     = ROOT_DIR + "log.txt"
LOCK_FILE    = ROOT_DIR + "todo.lock"
HISTORY_FILE = ROOT_DIR + "command_history.txt"

class AppIo
  PAGE_SIZE = 40
  MAX_HISTORY = 1000
  @@history_loaded = false

  def initialize
    load_history unless @@history_loaded
    @@history_loaded = true
  end

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
    input = Readline.readline('', false)
    if input && should_save_to_history?(input)
      Readline::HISTORY.push(input)
      save_history
    end
    input ? input + "\n" : input
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

  private

  def should_save_to_history?(input)
    return false if input.strip.empty?
    return false if input.strip == 'q'
    return false if !Readline::HISTORY.empty? && Readline::HISTORY.to_a.last == input
    true
  end

  def load_history
    return unless File.exist?(HISTORY_FILE)
    File.readlines(HISTORY_FILE).each do |line|
      Readline::HISTORY.push(line.chomp)
    end
  rescue
    # Ignore errors loading history
  end

  def save_history
    history = Readline::HISTORY.to_a.last(MAX_HISTORY)
    # Remove consecutive duplicates
    deduped_history = history.chunk { |x| x }.map(&:first)
    File.write(HISTORY_FILE, deduped_history.join("\n") + "\n")
  rescue
    # Ignore errors saving history
  end

end
