$:.unshift File.dirname(__FILE__)

require 'common'
require 'session'
require 'commands'
require 'appio'


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
                ToDoToday.new,
                ToDoEdit.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoMonthSummaries.new]

  def self.registered_commands
    @@commands
  end

  def initialize io
    ToDoUpdater.new.run
    @io = io
    @session = Session.new(io)
    @session.render
  end

  def run
    while true; on_line(@io.get_from_console.chomp); end
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


ToDo.new(AppIo.new).run




