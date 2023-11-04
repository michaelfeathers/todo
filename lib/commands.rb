$:.unshift File.dirname(__FILE__)

require 'session'
require 'appio'


class Command
  def run line, session
    return unless matches? line
    process line, session
  end

  def help_message
    "h    - help"
  end
end

class ToDoAdd < Command
  def matches? line
    line.split.take(1) == ["a"]
  end

  def process line, session
    session.todo_add(line.split.drop(1))
  end

  def help_message
    "a _  - add task"
  end
end

class ToDoQuit < Command
  def matches? line
    line.split == ["q"]
  end

  def process line, session
    session.todo_quit
  end

  def help_message
    "q    - save and quit"
  end
end

class ToDoCursorSet < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "c" 
  end

  def process line, session
    session.todo_cursor_set(line.split[1].to_i)
  end

  def help_message
    "c _  - set cursor position"
  end
end

class ToDoDown < Command
  def matches? line
    line.split == ["d"]
  end

  def process line, session
    session.todo_down
  end

  def help_message
    "d    - cursor down"
  end
end

class ToDoUp < Command
  def matches? line
    line.split == ["u"]
  end

  def process line, session
    session.todo_up
  end  
  
  def help_message
    "u    - sursor up"
  end
end

class ToDoFind < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "f"
  end

  def process line, session
    session.todo_find(line.split[1])
    gets
  end

  def help_message
    "f _  - find all tasks containing specified text"
  end
end

class ToDoPush < Command
  def matches? line
    line.split.count == 2 && line.split.take(1) == ["p"]
  end

  def process line, session
    session.todo_push line.split[1] 
  end

  def help_message
    "p _  - push foward x number of days"
  end
end

class ToDoRemove < Command
  def matches? line
    line.split == ["r"]
  end

  def process line, session
    session.todo_remove
  end

  def help_message
    "r    - remove task at cursor"
  end
end

class ToDoSave < Command
  def matches? line
    line.split == ["s"]
  end

  def process line, session
    session.todo_save
  end

  def help_message
    "s    - save task at cursor"
  end
end

class ToDoSaveNoRemove < Command
  def matches? line
    line.split == ["ss"]
  end

  def process line, session
    session.todo_save_no_remove
  end

  def help_message
    "ss   - save task at cursor without removing"
  end
end

class ToDoToday < Command
  def matches? line
    line.split == ["t"]
  end

  def process line, session
    session.todo_today
  end

  def help_message
    "t    - show tasks done today"
  end
end


class ToDoTrend < Command
  def matches? line
    line.split == ["tr"]
  end

  def process line, session
    session.todo_trend
  end

  def help_message
    "tr   - show trend: freqs for all days"
  end
end

=begin
class ToDoTrendChart < Command
  def matches? line
    line.split == ["tc"]
  end

  def process line, session
    session.todo_trend_chart
  end

  def help_message
    "tc   - show trend chart"
  end
end
=end

class ToDoEdit < Command
  def matches? line
    line.split.take(1) == ["e"]
  end

  def process line, session
    session.todo_edit(line.split.drop(1))
  end

  def help_message
   "e _  - edit task at cursor"
  end
end

class ToDoGrabToggle < Command
  def matches? line
    line.split.take(1) == ["g"]
  end

  def process line, session
    session.todo_grab_toggle
  end

  def help_message
   "g    - toggle grab mode"
  end  
end

class ToDoHelp < Command
  def matches? line
    line.split.take(1) == ["h"]
  end

  def process line, session
    puts $/ + ToDo.registered_commands.map {|c| c.help_message }.join($/)
    gets
  end

  def help_message
   "h    - show help message"
  end  
end

class ToDoMonthSummaries < Command
  def matches? line
    line.split.take(1) == ["m"]
  end

  def process line, session
    session.todo_month_summaries
  end

  def help_message
   "m    - show month summaries"
  end  
end

class ToDoPageDown < Command
  def matches? line
    line.split.take(1) == ["dd"]
  end

  def process line, session
    session.todo_page_down
  end

  def help_message
   "dd   - page down"
  end  
end

class ToDoPageUp < Command
  def matches? line
    line.split.take(1) == ["uu"]
  end

  def process line, session
    session.todo_page_up
  end

  def help_message
   "uu   - page up"
  end  
end

class ToDoZapToPosition < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "z" 
  end

  def process line, session
    session.todo_zap_to_position(line.split[1].to_i)
  end

  def help_message
    "z _  - zap (move) task at cursor to position"
  end

end







