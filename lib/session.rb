require_relative 'appio'
require_relative 'tasklist'


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
    io.clear_console

    tasklists = { '' => @foreground_tasks, 'Background:' => @background_tasks }

    tasklists.each do |label, task_list|
      found = task_list.find(text)
      next if found.empty?

      io.append_to_console "#{label}#{$/}" unless label.empty?
      io.append_to_console found.join + $/ + $/
    end
    io.get_from_console

  end

  def load_command_log
    content = @list.io.read_log
    parsed_data = content.split($/)
                         .map { |line| line.split(',') }
                         .select { |items| items.size == 2 }
                         .map { |k, v| [k, v.to_i] }
                         .to_h
    @command_log ||= parsed_data
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

  def surface count
    count.times do
      return if @background_tasks.empty?

      @background_tasks.cursor_set(rand(@background_tasks.count))
      task = @background_tasks.task_at_cursor
      @foreground_tasks.add(task)

      @background_tasks.remove_task_at_cursor
    end

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
    @list.io.get_from_console.chomp
  end

  def message_and_wait text
    @list.io.append_to_console text
    @list.io.get_from_console
  end

  def render
    io = @list.io
    return if io.suppress_render_list

    io.clear_console
    io.append_to_console @list.description

    lines = @list.window.map {|num, cursor, line| "%2d %s %s" % [num, cursor, line] }
                        .join

    io.append_to_console lines + $/
  end

end
