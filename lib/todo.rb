
require 'date'
require 'pp'

ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATER_FILE = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"
VIEW_LIMIT   = 45

CLEAR_SCREEN =  "\e[H\e[2J" 


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
    @session = Session.new
  end

  def run
    while true; on_line(gets.chomp); end
  end

  def on_line line
    @@commands.each {|c| c.run(line, @session) }
    @session.render
  end
end

class Session

  def todo_add tokens
    @actions = [tokens.join(" ") + $/] + @actions
    @cursor = 0
  end

  def todo_quit
    File.open(TODO_FILE, 'w') { |f| f.write(@actions.join) }
    exit
  end

  def todo_cursor_set line_no
    @cursor = line_no if (0...@actions.count).include?(line_no)
    # should this saturate?
  end

  def todo_down
    return unless @actions.count > 1 
    return unless @cursor < @actions.count - 1
    
    @actions.swap_elements(@cursor, @cursor + 1) if @grab_mode
    @cursor += 1
  end

  def todo_up
    return unless @actions.count > 1
    return unless @cursor > 0

    @actions.swap_elements(@cursor - 1, @cursor) if @grab_mode
    @cursor -= 1
  end

  def todo_find text
    puts CLEAR_SCREEN 
    found = @actions.each_with_index.map {|i,e| "%2d %s" % [e,i] }.grep(Regexp.new(text))
    puts found.join + $/ + found.count.to_s + $/ + $/
  end
  
  def todo_push days_text
    updates = File.read(UPDATER_FILE).lines.to_a
    date_text = DateTime.now.next_day(days_text.to_i).to_s[0, 10] 

    updates << [date_text, @actions[@cursor]].join(' ')
    updates = updates.sort_by {|line| DateTime.parse(line.split.first) }

    File.open(UPDATER_FILE, 'w') { |f| f.write(updates.join) }
    todo_remove
  end

  def todo_remove
    @actions.delete_at(@cursor)
    @cursor = [@cursor, @actions.count - 1].min
  end

  def todo_save
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(DateTime.now.to_s[0, 10] + " " + @actions[@cursor]) }
    todo_remove
  end

  def todo_save_no_remove
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(DateTime.now.to_s[0, 10] + " " + @actions[@cursor]) }
  end

  def todo_edit tokens
    @actions[@cursor] = tokens.join(" ") + $/
  end

  def todo_grab_toggle
    @grab_mode = (not @grab_mode)
  end
  
  def todo_month_summaries
    task_descs = File.read(ARCHIVE_FILE)
                      .lines
                      .map {|l| [DateTime.parse(l.split[0]), l.split[1].chars.first] }

   year_descs =  task_descs.select {|td| td.first.year == 2023 }
   puts "\n\n      %10s %10s %10s %10s" % ["R7K", "Globant", "Life", "Total"]
   puts ""
   (1..12).each do |month|
     puts "%s   %10d %10d %10d %10d" % [month_name_of(month), 
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "R" }.count,
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "G" }.count,       
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "L" }.count,
                                  year_descs.select {|d| d.first.month == month }.count]

   end
   puts ""
   puts "      %10d %10d %10d %10d" % [year_descs.select {|dd| dd[1] == "R" }.count,
                                       year_descs.select {|dd| dd[1] == "G" }.count,
                                       year_descs.select {|dd| dd[1] == "L" }.count,
                                       year_descs.count]

   puts ""

   todays = year_descs.select {|d| day_date(d.first) === day_date(DateTime.now) } 


   if todays.count > 0
     puts "Today %10d %10d %10d %10d" % [todays.select {|d| d[1] == "R" }.count,
                                         todays.select {|d| d[1] == "G" }.count,
                                         todays.select {|d| d[1] == "L" }.count,
                                         todays.count]
   else
     puts "Today %10d %10d %10d %10d" % [0, 0, 0, 0]
   end

   puts ""
   puts ""

   gets
  end

  def initialize
    ToDoUpdater.new.run    

    @cursor = 0
    @grab_mode = false
    @actions = File.read(TODO_FILE).lines
    render
  end

  def cursor_char index
    return " " unless @cursor == index
    @grab_mode ? "*" : "-"
  end

  def render
    puts CLEAR_SCREEN 
    index = 0
    @actions.each do |e|
      print ("%2d %s %s" % [index, cursor_char(index), e]) 
      break if index >= VIEW_LIMIT
      index = index + 1
    end
    print ("\n%s\n\n" % [index >= VIEW_LIMIT ? "..." : ""])

    # @actions.each_with_index {|e,i| print ("%2d %s %s" % [i, cursor_char(i), e]) }
    # puts ""
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

  def day_date dt
    DateTime.new(dt.year, dt.month, dt.day, 0, 0, 0, dt.zone)
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




