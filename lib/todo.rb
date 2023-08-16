$:.unshift File.dirname(__FILE__)

require 'common'
require 'session'
require 'date'


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
    puts "Remove current line (Y/N)?"
    response = gets

    session.todo_remove if response.split.first == "Y"
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




class ToDo
  @@commands = [ToDoAdd.new,
                ToDoQuit.new,
                ToDoCursorSet.new,
                ToDoDown.new,
                ToDoUp.new,
                ToDoFind.new,
                ToDoPush.new,
                ToDoRemove.new,
                ToDoSave.new,
                ToDoSaveNoRemove.new,
                ToDoEdit.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoMonthSummaries.new]

  def self.registered_commands
    @@commands
  end

  def initialize
    ToDoUpdater.new.run
    @session = Session.new
    @session.render
  end

  def run
    while true; on_line(gets.chomp); end
  end

  def on_line line
    @@commands.each {|c| c.run(line, @session) }
    @session.render
  end
end


class ToDoUpdater

  def run
    [[lines_of(TODO_FILE), lines_of(UPDATER_FILE)]]
      .map {|ts,us| [due(us) + ts, non_due(us)] }
      .each  do |ts,us| 
        write_lines(TODO_FILE, ts)
        write_lines(UPDATER_FILE, us.sort_by {|lines| DateTime.parse(lines.split.first)})
      end
  end

  def due us
    us.select {|e| due?(e)}
      .map {|e| strip_date(e)} 
  end

  def non_due us
     us.reject {|e| due?(e)}
  end

  def lines_of file_name
    File.read(file_name).lines
  end

  def write_lines file_name, lines
    File.open(file_name, 'w') { |f| f.write(lines.join) }
  end

  def strip_date line
    line.split.drop(1).join(" ") + $/
  end

  def due? line 
    tokens = line.split
    return false unless tokens.size > 0

    day_date(DateTime.parse(tokens.first)) <= day_date(DateTime.now)
  rescue
    false
  end
end



ToDo.new.run




