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
    session.on_list {|list| list.todo_trend_chart(opt_year) }
  end

  def description
    CommandDesc.new("tc", "show trend chart")
  end
end

class ToDoSaveActions < Command
  def matches?(line)
    line.split == ["@"]
  end

  def process(line, session)
    session.save
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
    session.on_list {|list| list.todo_push(line.split[1]) }
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
    session.on_list {|list| list.todo_remove }
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
    session.on_list {|list| list.todo_save }
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
    session.on_list {|list| list.todo_save_no_remove }
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
    session.on_list {|list| list.todo_show_updates }
  end

  def description
    CommandDesc.new("pp", "show updates")
  end
end

class ToDoIterativeFind < Command
  def matches?(line)
    (line.split in ["ff", *args]) && args.count <= 1
  end

  def process line, session
    text = line.split[1]
    session.on_list do |list|
      text ? list.todo_iterative_find_init(text) : list.todo_iterative_find_continue
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
    session.on_list {|list| list.todo_today(line.split.count == 1 ? 0 : line.split[1]) }
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
    session.on_list {|list| list.todo_trend }
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
    session.on_list {|list| list.todo_grab_toggle }
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

class ToDoPageDown < Command
  def matches? line
    line.split == ["dd"]
  end

  def process line, session
    session.on_list {|list| list.todo_page_down }
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
    session.on_list {|list| list.todo_page_up }
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
    session.on_list {|list| list.todo_print_archive }
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
    session.on_list {|list| list.todo_zap_to_position(line.split[1].to_i) }
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
    session.on_list {|list| list.todo_target_for(line.split[1].to_i) }
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
    session.on_list {|list| list.todo_retag(line.split[1]) }
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
    session.on_list {|list| list.todo_tag_tallies }
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
    target_position = nil
    tokens = line.split

    target_position = tokens[1].to_i if tokens.count == 2

    session.switch_lists(target_position)
  end

  def description
    CommandDesc.new("w [n]", "switch foreground and background lists, optionally moving cursor to position n")
  end
end

class ToDoShowCommandFrequencices  < Command
  def matches? line
    line.split == ["sf"]
  end

  def process line, session
    session.on_list {|list| list.todo_show_command_frequencies }
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
    session.on_list {|list| list.todo_zap_to_top }
  end

  def description
    CommandDesc.new("zz", "move the task at the cursor to the top (position 0)")
  end
end
