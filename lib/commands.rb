$:.unshift File.dirname(__FILE__)

require 'session'
require 'appio'



CommandDesc = Struct.new(:name, :line)


class CommandResult
  attr_reader :matches

  def initialize
    @matches = []
  end

  def record_match command
    @matches << command
  end

  def match_count
    @matches.count
  end
end

class Command

  def run line, session, result = CommandResult.new
    return unless matches? line
    result.record_match(self)
    process line, session
  end

  def name
    description.name.split.first
  end

end

class ToDoAdd < Command
  def matches? line
    line.split.take(1) == ["a"]
  end

  def process line, session
    session.list.todo_add(line.split.drop(1))
  end

  def description
    CommandDesc.new("a  text", "add text as a task")
  end
end

class ToDoQuit < Command
  def matches? line
    line.split == ["q"]
  end

  def process line, session
    session.save
    exit
  end

  def description
    CommandDesc.new("q", "save and quit")
  end
end

class ToDoCursorSet < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "c" 
  end

  def process line, session
    session.list.todo_cursor_set(line.split[1].to_i)
  end

  def description
    CommandDesc.new("c  n", "set cursor position to line n")
  end
end

class ToDoDown < Command
  def matches? line
    line.split == ["d"]
  end

  def process line, session
    session.list.todo_down
  end

  def description
    CommandDesc.new("d", "move cursor down")
  end
end

class ToDoUp < Command
  def matches? line
    line.split == ["u"]
  end

  def process line, session
    session.list.todo_up
  end  

  def description
    CommandDesc.new("u", "move cursor up")
  end
end

class ToDoFind < Command
  def matches? line
     (2..3).include?(line.split.count) && line.split[0] == "f"
  end

  def process line, session
    limit = line.split.count == 3 ? line.split[2].to_i : nil
    session.list.todo_find(line.split[1], limit)
  end

  def description
    CommandDesc.new("f  text [n]", "find all (or [n]) tasks containing specified text")
  end
end

class ToDoGlobalFind < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "gf"
  end

  def process line, session
    session.global_find(line.split[1])
  end

  def description
    CommandDesc.new("gf text", "find text across all task lists")
  end
end

class ToDoInsertBlank < Command
  def matches?(line)
    line.strip == "i"  
  end

  def process(line, session)
    session.list.todo_insert_blank
  end

  def description
    CommandDesc.new("i", "insert a blank line at the cursor")
  end
end


class ToDoPush < Command
  def matches? line
    line.split.count == 2 && line.split.take(1) == ["p"]
  end

  def process line, session
    session.list.todo_push line.split[1] 
  end

  def description
    CommandDesc.new("p  n", "push task at cursor forward n number of days")
  end
end

class ToDoRemove < Command
  def matches? line
    line.split == ["r"]
  end

  def process line, session
    session.list.todo_remove
  end

  def description
    CommandDesc.new("r", "remove task at cursor")
  end
end

class ToDoSave < Command
  def matches? line
    line.split == ["s"]
  end

  def process line, session
    session.list.todo_save
  end

  def description
    CommandDesc.new("s", "save task at cursor")
  end
end

class ToDoSaveNoRemove < Command
  def matches? line
    line.split == ["ss"]
  end

  def process line, session
    session.list.todo_save_no_remove
  end

  def description
    CommandDesc.new("ss", "save task at cursor without removing")
  end
end

class ToDoShowUpdates < Command
  def matches? line
    line.split == ["pp"]
  end

  def process line, session
    session.list.todo_show_updates
  end

  def description
    CommandDesc.new("pp", "show updates")
  end
end

class ToDoToday < Command
  def matches? line
    (1..2).include?(line.split.count) && line.split.first == "t"
  end

  def process line, session
    session.list.todo_today(line.split.count == 1 ? 0 : line.split[1])
  end

  def description
    CommandDesc.new("t  [n]", "show tasks n days prev. If no arg, defaults to today") 
  end
end

class ToDoTrend < Command
  def matches? line
    line.split == ["tr"]
  end

  def process line, session
    session.list.todo_trend
  end

  def description
    CommandDesc.new("tr", "show trend") 
  end
end

=begin
class ToDoTrendChart < Command
  def matches? line
    line.split == ["tc"]
  end

  def process line, session
    session.list.todo_trend_chart
  end
end
=end

class ToDoEdit < Command
  def matches? line
    line.split.take(1) == ["e"]
  end

  def process line, session
    session.list.todo_edit(line.split.drop(1))
  end

  def description
    CommandDesc.new("e  text", "edit task at cursor, replacing it with text") 
  end
end

class ToDoEditReplace < Command
  def matches? line
    line.split.take(1) == ["er"] && line.split.count == 3
  end

  def process line, session
    old_token = line.split[1]
    new_token = line.split[2]
    session.list.todo_edit_replace(old_token, new_token)
  end

  def description
    CommandDesc.new("er match replacement", "replace match with replacement in current task") 
  end
end

class ToDoGrabToggle < Command
  def matches? line
    line.split.take(1) == ["g"]
  end

  def process line, session
    session.list.todo_grab_toggle
  end

  def description
    CommandDesc.new("g", "toggle grab mode")
  end
end

class ToDoHelp < Command
  def matches? line
    line.split.take(1) == ["h"]
  end

  def process line, session
    session.list.todo_help(ToDo.registered_commands.map { |c| [c.description.name, c.description.line] })
  end

  def description
    CommandDesc.new("h", "show help message")
  end
end

class ToDoMonthSummaries < Command
  def matches? line
    (1..2).include?(line.split.count) && line.split.first == "m"
  end

  def process line, session
    session.list.todo_month_summaries if line.split.count == 1
    session.list.todo_month_summaries(line.split[1]) if line.split.count == 2
  end

  def description
    CommandDesc.new("m", "show month summaries") 
  end
end

class ToDoPageDown < Command
  def matches? line
    line.split.take(1) == ["dd"]
  end

  def process line, session
    session.list.todo_page_down
  end

  def description
    CommandDesc.new("dd", "page down")
  end
end

class ToDoPageUp < Command
  def matches? line
    line.split.take(1) == ["uu"]
  end

  def process line, session
    session.list.todo_page_up
  end

  def description
    CommandDesc.new("uu", "page up")
  end
end

class ToDoZapToPosition < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "z" 
  end

  def process line, session
    session.list.todo_zap_to_position(line.split[1].to_i)
  end

  def description
    CommandDesc.new("z  n", "move (zap) task at cursor to line n")
  end
end

class ToDoTodayTargetFor < Command
  def matches? line
    line.split.count == 2 && line.split[0] == "tf" 
  end

  def process line, session
    session.list.todo_today_target_for(line.split[1].to_i)
  end

  def description
    CommandDesc.new("tf n", "show how many more tasks are needed today to stay on track for n this month")
  end
end

class ToDoSurface < Command
  def matches? line
    line.split.count >= 1 && line.split[0] == "su" 
  end

  def process line, session
    count_items = line.split.count > 1 ? line.split[1].to_i : 1
    session.list.todo_surface(count_items)
  end

  def description
    CommandDesc.new("su", "surface the last task by putting it first")
  end
end

class ToDoReTag < Command 
  def matches? line
    line.split.count == 2 && line.split[0] == "rt"
  end

  def process line, session
    session.list.todo_retag(line.split[1])
  end

  def description
    CommandDesc.new("tr tag", "re-tag the task at the cursor with tag. Tag if not tagged")
  end
end

class ToDoTagTallies < Command 
  def matches? line
    line.split.count == 1 && line.split[0] == "tt"
  end

  def process line, session
    session.list.todo_tag_tallies
  end

  def description
    CommandDesc.new("tt", "show tally of all tag types")
  end
end

class ToDoSwitchLists < Command
  def matches? line
    line.split.count == 1 && line.split[0] == "w"
  end

  def process line, session
    session.switch_lists
  end

  def description
    CommandDesc.new("w", "switch foreground and background lists")
  end
end

class ToDoMoveTaskToOther < Command
  def matches? line
    line.split.count == 1 && line.split[0] == "-"
  end

  def process line, session
    session.move_task_to_other
  end

  def description
    CommandDesc.new("-", "move task to other list")
  end
end

class ToDoShowCommandFrequencices  < Command
  def matches? line
    line.split.count == 1 && line.split[0] == "sf"
  end

  def process line, session
    session.list.todo_show_command_frequencies
  end

  def description
    CommandDesc.new("sf ", "show command frequencies")
  end
end



