$:.unshift File.dirname(__FILE__)


ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATER_FILE = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"

class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end
end

def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end

def day_date dt
  DateTime.new(dt.year, dt.month, dt.day, 0, 0, 0, dt.zone)
end




