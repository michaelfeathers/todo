$:.unshift File.dirname(__FILE__)

require 'fileutils'
require 'session'
require 'commands'
require 'appio'
require 'backgroundio'
require 'headlessio.rb'
require 'todoupdater'


class ToDo
  @@commands = [ToDoAdd.new,
                ToDoCursorSet.new,
                ToDoCursorToStart.new,
                ToDoDisplayEdit.new,
                ToDoDown.new,
                ToDoEdit.new,
                ToDoEditReplace.new,
                ToDoFind.new,
                ToDoGlobalFind.new,
                ToDoGrabToggle.new,
                ToDoHelp.new,
                ToDoInsertBlank.new,
                ToDoIterativeFind.new,
                ToDoMonthSummaries.new,
                ToDoMoveTaskToOther.new,
                ToDoMoveToRandomPositionOnOtherList.new,
                ToDoPageDown.new,
                ToDoPageUp.new,
                ToDoPrintArchive.new,
                ToDoPush.new,
                ToDoQuit.new,
                ToDoReTag.new,
                ToDoRemove.new,
                ToDoSave.new,
                ToDoSaveActions.new,
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
                ToDoZapToPosition.new,
                ToDoZapToTop.new]
  

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


def run
  if File.exist?(LOCK_FILE)
    puts "Another instance of todo is already running."
    exit
  end

  begin
    FileUtils.touch(LOCK_FILE)

    if ARGV.length == 0
      ToDo.new(AppIo.new, BackgroundIo.new).run
    else
      ToDo.new(HeadlessIo.new, HeadlessIo.new).run
  end

  ensure
    FileUtils.rm(LOCK_FILE) if File.exist?(LOCK_FILE)
  end
end


run


