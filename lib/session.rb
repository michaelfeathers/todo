require_relative 'appio'
require_relative 'tasklist'
require_relative 'consolerenderer'
require_relative 'nullrenderer'


class Session

  attr_reader :list

  def self.from_ios foreground_io, background_io
    @foreground_tasks = TaskList.new(foreground_io)
    @background_tasks = TaskList.new(background_io, "BACKGROUND")
    new(@foreground_tasks, @background_tasks)
  end

  def initialize foreground_tasks, background_tasks
    @foreground_tasks = foreground_tasks
    @background_tasks = background_tasks

    @list = @foreground_tasks
    load_command_log
  end

  def on_list
    yield @list
  end

  def switch_lists(target_position = nil)
    toggle_active_list
    @list.cursor_set(target_position) if target_position
  end

  def toggle_active_list
    @list = @list.equal?(@foreground_tasks) ? @background_tasks : @foreground_tasks
  end

  def move_task_to_other
    task = @list.task_at_cursor
    @list.remove_task_at_cursor

    switch_lists
    @list.add(task)
    switch_lists
  end

  def save
    @foreground_tasks.save_all
    @background_tasks.save_all
  end

  def add task_line
    @foreground_tasks.add task_line
  end

  def global_find(text)
    io = @list.io

    # Build output for foreground tasks
    found_foreground = @foreground_tasks.find(text)
    foreground_output = ""
    unless found_foreground.empty?
      foreground_output = found_foreground.join + $/ + $/
    end

    # Build output for background tasks
    found_background = @background_tasks.find(text)
    background_output = ""
    unless found_background.empty?
      background_output = "Background:#{$/}" + found_background.join + $/ + $/
    end

    # Combine outputs and display with pagination
    combined_output = foreground_output + background_output
    io.display_paginated(combined_output)
    io.get_from_console

  end

  def load_command_log
    @command_log = @list.io.read_log
                         .split($/)
                         .map { |line| line.split(',') }
                         .select { |items| items.size == 2 }
                         .map { |k, v| [k, v.to_i] }
                         .to_h
    @command_log.default = 0
    @command_log
  end

  def log_command name
    text = @command_log.tap { |h| h[name] += 1 }
                       .sort_by { |_, v| -v }
                       .to_h
                       .map { |k, v| "#{k},#{v}" }
                       .join($/)

    @list.io.write_log(text)
  end

  def move_task_to_random_position_on_other_list
    task = @list.task_at_cursor
    @list.remove_task_at_cursor

    other_list = (@list == @foreground_tasks) ? @background_tasks : @foreground_tasks
    random_position = rand(other_list.count)

    other_list.add(task)
    other_list.todo_zap_to_position(random_position)
  end

  def get_line
    input = @list.io.get_from_console
    input ? input.chomp : ""
  end

  def message_and_wait text
    @list.io.append_to_console text
    @list.io.get_from_console
  end

  def render renderer = nil
    renderer ||= @list.io.renderer
    renderer.render(@list)
  end

end
