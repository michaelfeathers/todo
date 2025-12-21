require 'rubygems'
require 'bundler/setup'
require 'fileutils'
require_relative 'lib/session'
require_relative 'lib/commands'
require_relative 'lib/appio'
require_relative 'lib/backgroundio'
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
                MoveToRandomPositionOnOtherList.new,
                PageDown.new,
                PageUp.new,
                PrintArchive.new,
                Push.new,
                Quit.new,
                Retag.new,
                Remove.new,
                Save.new,
                SaveActions.new,
                SaveNoRemove.new,
                SaveToYesterday.new,
                ShowCommandFrequencies.new,
                ShowUpdates.new,
                SwitchLists.new,
                TagTallies.new,
                TodayTargetFor.new,
                Today.new,
                Trend.new,
                TrendChart.new,
                Up.new,
                ZapToPosition.new,
                ZapToTop.new]


  def self.registered_commands
    @@commands
  end

  def initialize foreground_io, background_io
    @foreground_io = foreground_io
    @background_io = background_io
    ToDoUpdater.new(@foreground_io).run
    @session = Session.from_ios(@foreground_io, @background_io)
    @headless = !ARGV.empty?
    @session.render unless @headless
  end

  def run
    # Headless mode: process ARGV and exit
    if @headless
      on_line(ARGV.join(' '), @session)
      return
    end

    # Interactive mode: run the main loop
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
