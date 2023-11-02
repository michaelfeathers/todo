$:.unshift File.dirname(__FILE__)

require 'session'
require 'commands'
require 'appio'
require 'todoupdater'


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
                ToDoTrend.new,
                ToDoTrendChart.new,
                ToDoEdit.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoMonthSummaries.new,
                ToDoPageDown.new,
                ToDoPageUp.new,
                ToDoZapToPosition.new]

  def self.registered_commands
    @@commands
  end

  def initialize io
    ToDoUpdater.new(io).run
    @io = io
    @session = Session.new(io)
    @session.surface(1)
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


ToDo.new(AppIo.new).run

