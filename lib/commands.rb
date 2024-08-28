require 'gruff'
require_relative 'command'
require_relative 'session'
require_relative 'appio'


class ToDoTrendChart < Command
  def matches? line
    (line.split in ["tc", *args]) && args.count <= 1
  end

  def process line, session
    opt_year = line.split[1] if line.split.count == 2
    session.list.todo_trend_chart opt_year
  end

  def description
    CommandDesc.new("tc", "show trend chart")
  end
end

class ToDoFind < Command
  def matches? line
    (line.split in ["f", *args]) && args.count >= 1
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
    (line.split in ["gf", *args]) && args.count == 1
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
    line.split == ["i"]
  end

  def process(line, session)
    session.list.todo_insert_blank
  end

  def description
    CommandDesc.new("i", "insert a blank line at the cursor")
  end
end

class ToDoSaveActions < Command
  def matches?(line)
    line.split == ["@"]
  end

  def process(line, session)
    session.list.todo_save_all
  end

  def description
    CommandDesc.new("@", "save the tasks without quitting")
  end
end

class ToDoPush < Command
  def matches? line
    (line.split in ["p", *args]) && args.count == 1
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

class ToDoIterativeFind < Command
  def matches?(line)
    (line.split in ["ff", *args]) && args.count <= 1
  end

  def process(line, session)
    tokens = line.split
    if tokens.count > 1
      text = tokens[1]
      session.list.todo_iterative_find_init(text)
    else
      session.list.todo_iterative_find_continue
    end
  end

  def description
    CommandDesc.new("ff [text]", "find the first occurrence of text starting from the cursor position (or from the top if text is provided")
  end
end

class ToDoToday < Command
  def matches? line
    (line.split in ["t", *args]) && args.count <= 1
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

class ToDoGrabToggle < Command
  def matches? line
    line.split == ["g"]
  end

  def process line, session
    session.list.todo_grab_toggle
  end

  def description
    CommandDesc.new("g", "toggle grab mode")
  end
end

class ToDoMoveToRandomPositionOnOtherList < Command
  def matches?(line)
    line.split == ["_"]
  end

  def process(line, session)
    return if session.list.empty?
    session.move_task_to_random_position_on_other_list
  end

  def description
    CommandDesc.new("_", "move the task at the cursor to a random position on the other list")
  end
end

class ToDoHelp < Command
  def matches? line
    line.split == ["h"]
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
    (line.split in ["m", *args]) && args.count <= 1
  end

  def process line, session
    session.list.todo_month_summaries if line.split.count == 1
    session.list.todo_month_summaries(line.split[1].to_i) if line.split.count == 2
  end

  def description
    CommandDesc.new("m", "show month summaries")
  end
end

class ToDoPageDown < Command
  def matches? line
    line.split == ["dd"]
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
    line.split == ["uu"]
  end

  def process line, session
    session.list.todo_page_up
  end

  def description
    CommandDesc.new("uu", "page up")
  end
end

class ToDoPrintArchive < Command
  def matches?(line)
    line.split == ["pa"]
  end

  def process line, session
    session.list.todo_print_archive
  end

  def description
    CommandDesc.new("pa", "print the archive")
  end
end

class ToDoZapToPosition < Command
  def matches? line
    (line.split in ["z", *args]) && args.count == 1
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
    (line.split in ["tf", *args]) && args.count == 1
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
    (line.split in ["su", *args]) && args.count <= 1
  end

  def process line, session
    count_items = line.split.count > 1 ? line.split[1].to_i : 1
    session.surface(count_items)
  end

  def description
    CommandDesc.new("su", "surface the last task by putting it first")
  end
end

class ToDoReTag < Command
  def matches? line
    (line.split in ["rt", *args]) && args.count == 1
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
    line.split == ["tt"]
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
    (line.split in ["w", *args]) && (args.count == 0 || (args.count == 1 && args[0] =~ /^\d+$/))
  end

  def process line, session
    tokens = line.split
    if tokens.count == 2
      target_position = tokens[1].to_i
    else
      target_position = nil
    end

    session.switch_lists(target_position)
  end

  def description
    CommandDesc.new("w [n]", "switch foreground and background lists, optionally moving cursor to position n")
  end
end

class ToDoMoveTaskToOther < Command
  def matches? line
    line.split == ["-"]
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
    line.split == ["sf"]
  end

  def process line, session
    session.list.todo_show_command_frequencies
  end

  def description
    CommandDesc.new("sf ", "show command frequencies")
  end
end

class ToDoZapToTop < Command
  def matches?(line)
    line.split == ["zz"]
  end

  def process(line, session)
    session.list.todo_zap_to_top
  end

  def description
    CommandDesc.new("zz", "move the task at the cursor to the top (position 0)")
  end
end
