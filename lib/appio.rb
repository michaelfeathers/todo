ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/data/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATE_FILE  = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"
JUNK_FILE    = ROOT_DIR + "junk.txt"
LOG_FILE     = ROOT_DIR + "log.txt"
LOCK_FILE    = ROOT_DIR + "todo.lock"

class AppIo
  def read_archive
    File.read(ARCHIVE_FILE)
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

  def suppress_render_list
    false
  end
end
