$:.unshift File.dirname(__FILE__)

require 'session'
require 'commands'
require 'appio'
require 'backgroundio'
require 'headlessio.rb'
require 'todoupdater'


require 'gruff'

class ToDoTrendChart < Command
  def matches? line
    (1..2).include?(line.split.count) && line.split.first == "tc"
  end

  def process line, session
    opt_year = line.split[1] if line.split.count == 2
    session.list.todo_trend_chart opt_year
  end

  def description
    CommandDesc.new("tc", "show trend chart")
  end
end


class TaskList
  def todo_trend_chart opt_year
    g = Gruff::Line.new(1600)
    g.theme = {
      colors: %w[red],
      marker_color: 'gray',
      font_color: 'black',
      background_colors: 'white'
    }
    g.data('', day_frequencies(opt_year).map {|e| e[1] })  
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
                ToDoGlobalFind.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoMonthSummaries.new,
                ToDoMoveTaskToOther.new,
                ToDoPageDown.new,
                ToDoPageUp.new,
                ToDoPush.new,
                ToDoQuit.new,
                ToDoReTag.new,
                ToDoRemove.new,
                ToDoSave.new,
                ToDoSaveNoRemove.new,
                ToDoShowCommandFrequencices.new,
                ToDoShowUpdates.new,
                ToDoSurface.new,
                ToDoSwitchLists.new,
                ToDoTagTallies.new,
                ToDoTodayTargetFor.new,
                ToDoToday.new,
                ToDoTrend.new,
                ToDoTrendChart.new,
                ToDoUp.new,
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
    while true 
      on_line(@session.list.io.get_from_console.chomp, @session)
      @session.list.render
    end
  end

  def on_line line, session
    result = CommandResult.new
    @@commands.each {|c| c.run(line, session, result) }
    @session.log_command(result.matches.first.name) if result.match_count > 0
    process_result(result, line)
  end

  def process_result result, line
    return unless result.match_count == 0 && line.split.count > 0
    @session.list.io.append_to_console("Unrecognized command: " + line + $/)
    @session.list.io.get_from_console
  end

end

if ARGV.length == 0
  ToDo.new(AppIo.new, BackgroundIo.new).run
else
  ToDo.new(HeadlessIo.new, HeadlessIo.new).run
end

