$:.unshift File.dirname(__FILE__)

require 'session'
require 'commands'
require 'appio'
require 'backgroundio'
require 'todoupdater'


require 'gruff'

class ToDoTrendChart < Command
  def matches? line
    line.split == ["tc"]
  end

  def process line, session
    session.todo_trend_chart
  end

  def description
    CommandDesc.new("tc", "show tend chart")
  end
end


class Session
  def todo_trend_chart
    g = Gruff::Line.new(1600)
    g.theme = {
      colors: %w[red],
      marker_color: 'gray',
      font_color: 'black',
      background_colors: 'white'
    }
    g.data('', day_frequencies.map {|e| e[1] })  
    g.write('trend.png')
    `open trend.png`
  end
end




class ToDo
  @@commands = [ToDoAdd.new,
                ToDoCursorSet.new,
                ToDoDown.new,
                ToDoEdit.new,
                ToDoFind.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoMonthSummaries.new,
                ToDoPageDown.new,
                ToDoPageUp.new,
                ToDoPush.new,
                ToDoQuit.new,
                ToDoReTag.new,
                ToDoRemove.new,
                ToDoSave.new,
                ToDoSaveNoRemove.new,
                ToDoSurface.new,
                ToDoToday.new,
                ToDoTrend.new,
                ToDoTrendChart.new,
                ToDoUp.new,
                ToDoTagTallies.new,
                ToDoSwitchLists.new,
                ToDoZapToPosition.new]

  def self.registered_commands
    @@commands
  end

  def initialize foreground_io, background_io
    @foreground_io = foreground_io
    @background_io = background_io
    ToDoUpdater.new(@foreground_io).run
    @session = Session.new(@foreground_io, @background_io)
    @session.list.render
  end

  def run
    while true; on_line(@session.list.io.get_from_console.chomp); end
  end

  def on_line line
    result = CommandResult.new
    @@commands.each {|c| c.run(line, @session, result) }
    process_result(result, line)
    @session.list.render
  end

  def process_result result, line
    return unless result.match_count == 0 && line.split.count > 0
    @session.list.io.append_to_console("Unrecognized command: " + line + $/)
    @session.list.io.get_from_console
  end

end


ToDo.new(AppIo.new, BackgroundIo.new).run

