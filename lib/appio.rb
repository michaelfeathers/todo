$:.unshift File.dirname(__FILE__)

require 'common'


class AppIo
  def read_archive
    File.read(ARCHIVE_FILE)
  end
  
  def read_actions
    File.read(TODO_FILE)
  end
  
  def write_actions actions
    File.open(TODO_FILE, 'w') { |f| f.write(actions.join) }
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
