require 'rubygems'
require 'bundler/setup'
require 'fileutils'
require_relative 'lib/session'

require_relative 'lib/commands'
require_relative 'lib/commands/add'
require_relative 'lib/commands/cursor_set'
require_relative 'lib/commands/cursor_to_start'
require_relative 'lib/commands/display_edit'
require_relative 'lib/commands/down'
require_relative 'lib/commands/edit'
require_relative 'lib/commands/edit_insert'
require_relative 'lib/commands/edit_replace'
require_relative 'lib/commands/find'
require_relative 'lib/commands/global_find'
require_relative 'lib/commands/grab_toggle'
require_relative 'lib/commands/help'
require_relative 'lib/commands/insert_blank'
require_relative 'lib/commands/iterative_find'
require_relative 'lib/commands/month_summaries'
require_relative 'lib/commands/move_task_to_other'
require_relative 'lib/commands/save_to_yesterday'
require_relative 'lib/commands/quit'
require_relative 'lib/commands/up'

require_relative 'lib/appio'
require_relative 'lib/backgroundio'
require_relative 'lib/headlessio.rb'
require_relative 'lib/todoupdater'


class ToDo
  @@commands = [Add.new,
                CursorSet.new,
                CursorToStart.new,
                DisplayEdit.new,
                Down.new,
                Edit.new,
                EditInsert.new,
                EditReplace.new,
                Find.new,
                GlobalFind.new,
                GrabToggle.new,
                Help.new,
                InsertBlank.new,
                IterativeFind.new,
                MonthSummaries.new,
                MoveTaskToOther.new,
                ToDoMoveToRandomPositionOnOtherList.new,
                ToDoPageDown.new,
                ToDoPageUp.new,
                ToDoPrintArchive.new,
                ToDoPush.new,
                Quit.new,
                ToDoReTag.new,
                ToDoRemove.new,
                ToDoSave.new,
                ToDoSaveActions.new,
                ToDoSaveNoRemove.new,
                SaveToYesterday.new,
                ToDoShowCommandFrequencices.new,
                ToDoShowUpdates.new,
                ToDoSurface.new,
                ToDoSwitchLists.new,
                ToDoTagTallies.new,
                ToDoTodayTargetFor.new,
                ToDoToday.new,
                ToDoTrend.new,
                ToDoTrendChart.new,
                Up.new,
                ToDoZapToPosition.new,
                ToDoZapToTop.new]


  def self.registered_commands
    @@commands
  end

  def initialize foreground_io, background_io
    @foreground_io = foreground_io
    @background_io = background_io
    ToDoUpdater.new(@foreground_io).run
    @session = Session.from_ios(@foreground_io, @background_io)
    @session.render
  end

  def run
    while true
      on_line(@session.get_line, @session)
      @session.render
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
    @session.message_and_wait("Unrecognized command: " + line + $/)
  end

end


def run
  return puts "Another instance of todo is already running." if File.exist?(LOCK_FILE)

  FileUtils.touch(LOCK_FILE)
  ios = ARGV.empty? ? [AppIo, BackgroundIo] : [HeadlessIo, HeadlessIo]
  ToDo.new(*ios.map(&:new)).run
ensure
  FileUtils.rm(LOCK_FILE) if File.exist?(LOCK_FILE)
end

run
