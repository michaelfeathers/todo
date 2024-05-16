$:.unshift File.dirname(__FILE__)

require 'appio'
require 'tasklist'


class Session

  attr_reader :list


  def initialize foreground_io, background_io
    @foreground_tasks = TaskList.new(foreground_io)
    @background_tasks = TaskList.new(background_io, "BACKGROUND")
    @command_log = {}

    @list = @foreground_tasks
    load_command_log
  end

  def switch_lists(target_position = nil)
    toggle_active_list
    @list.todo_cursor_set(target_position) if target_position
  end

  def toggle_active_list
    @list = @list.equal?(@foreground_tasks) ? @background_tasks : @foreground_tasks
  end

  def move_task_to_other
    task = @list.action_at_cursor 
    @list.remove_action_at_cursor

    switch_lists
    @list.todo_add(task.split.join(" "))
    switch_lists
  end

  def save
    @foreground_tasks.save_all
    @background_tasks.save_all
  end

  def add task_line
    @background_tasks.todo_add task_line
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

  def load_command_log 
    @command_log = list.io.read_log 
                          .split($/)
                          .map { |line| line.split(',') } 
                          .select { |items| items.size == 2 } 
                          .map { |k, v| [k, v.to_i] } 
                          .to_h
                          .tap { |h| h.default = 0 }
  end

  def log_command name
    text = @command_log.tap { |h| h[name] += 1 }
                       .sort_by { |_, v| -v } 
                       .to_h 
                       .map { |k, v| "#{k},#{v}" } 
                       .join($/)

    list.io.write_log(text)
  end

  def surface count
    count.times do
      return if @background_tasks.empty?

      @background_tasks.todo_cursor_set(rand(@background_tasks.count))
      task = @background_tasks.action_at_cursor
      @foreground_tasks.todo_add(task)

      @background_tasks.remove_action_at_cursor
    end
    
  end

  def move_task_to_random_position_on_other_list
    task = @list.action_at_cursor
    @list.remove_action_at_cursor

    other_list = (@list == @foreground_tasks) ? @background_tasks : @foreground_tasks
    random_position = rand(other_list.count)

    other_list.todo_add(task)
    other_list.todo_zap_to_position(random_position)
  end

end



