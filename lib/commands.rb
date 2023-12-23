$:.unshift File.dirname(__FILE__)

require 'session'
require 'appio'



CommandDesc = Struct.new(:name, :line)


class CommandResult
  attr_reader :match_count

  def initialize
    @match_count = 0
  end

  def record_match
    @match_count = @match_count + 1
  end
end

class Command

  def run line, session, result = CommandResult.new
    return unless matches? line
    result.record_match
    process line, session
  end

end

class ToDoAdd < Command
  def matches? line
    line.split.take(1) == ["a"]
  end

  def process line, session
    session.todo_add(line.split.drop(1))
  end

  def description
    CommandDesc.new("a", "add task")
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

  def description
    CommandDesc.new("q", "save and quit")
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

  def description
    CommandDesc.new("c", "set cursor position")
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

  def description
    CommandDesc.new("d", "move cursor down")
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

  def description
    CommandDesc.new("u", "move cursor up")
  end
  
  def help_message
    "u    - cursor up"
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

  def description
    CommandDesc.new("f", "find all tasks containing specified text")
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

  def description
    CommandDesc.new("p", "push forward x number of days")
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

  def description
    CommandDesc.new("r", "remove task at cursor")
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

  def description
    CommandDesc.new("s", "save task at cursor")
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

  def description
    CommandDesc.new("ss", "save task at cursor without removing")
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

  def description
    CommandDesc.new("t", "show tasks done today")
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

  def description
    CommandDesc.new("tr", "show trend") 
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

  def description
    CommandDesc.new("e", "end task at cursor") 
  end

  def help_message
   "e    - edit task at cursor"
  end
end

class ToDoGrabToggle < Command
  def matches? line
    line.split.take(1) == ["g"]
  end

  def process line, session
    session.todo_grab_toggle
  end

  def description
    CommandDesc.new("g", "toggle grab mode")
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
    session.todo_help(ToDo.registered_commands.map { |c| [c.description.name, c.description.line] })
    gets
  end

  def description
    CommandDesc.new("h", "show help message")
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

  def description
    CommandDesc.new("m", "show month summaries") 
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

  def description
    CommandDesc.new("dd", "page down")
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

  def description
    CommandDesc.new("uu", "page up")
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

  def description
    CommandDesc.new("z", "move (zap) task at cursor to position")
  end

  def help_message
    "z _  - zap (move) task at cursor to position"
  end

end


class ToDoSurface < Command
  def matches? line
    line.split.count == 1 && line.split[0] == "su" 
  end

  def process line, session
    session.todo_surface(1)
  end

  def description
    CommandDesc.new("su", "surfae the last task by putting it first")
  end

  def help_message
    "su   - surface the last task by putting it first" 
  end
end


class ToDoReTag < Command 
  def matches? line
    line.split.count == 2 && line.split[0] == "rt"
  end

  def process line, session
    session.todo_retag(line.split[1])
  end

  def description
    CommandDesc.new("tr", "re-tag the task at the cursor")
  end

  def help_message
    "rt   - re tag the task at the cursor" 
  end

end








