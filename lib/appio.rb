$:.unshift File.dirname(__FILE__)

ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATE_FILE  = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"


class AppIo
  def read_archive
    File.read(ARCHIVE_FILE)
  end
  
  def append_to_archive line
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(line); }
  end

  def read_actions
    File.read(TODO_FILE)
  end
  
  def write_actions actions
    File.open(TODO_FILE, 'w') { |f| f.write(actions.join) }
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
end
