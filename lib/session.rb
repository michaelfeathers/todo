$:.unshift File.dirname(__FILE__)

require 'appio'
require 'tasklist'


class Session

  attr_reader :list


  def initialize foreground_io, background_io
    @foreground_tasks = TaskList.new(foreground_io)
    @background_tasks = TaskList.new(background_io, "BACKGROUND")

    @list = @foreground_tasks
  end

  def switch_lists 
    @list = @list.equal?(@foreground_tasks) ? @background_tasks : @foreground_tasks
  end

  def save
    @foreground_tasks.save_all
    @background_tasks.save_all
  end

end



