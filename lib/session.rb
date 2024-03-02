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

  def move_task_to_other
    task = @list.action_at_cursor 
    @list.remove_action_at_cursor

    switch_lists
    @list.todo_add(task.split)
    switch_lists
  end

  def save
    @foreground_tasks.save_all
    @background_tasks.save_all
  end

  def global_find(text)
    io = list.io 
    io.clear_console

    tasks = { '' => @foreground_tasks, 'Background:' => @background_tasks }

    tasks.each do |label, task_list|
      found = task_list.find(text)
      next if found.empty?

      io.append_to_console "#{label}#{$/}" unless label.empty?
      io.append_to_console found.join + $/ + $/
    end
    io.get_from_console
  end

end



