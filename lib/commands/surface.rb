require_relative '../command'
require_relative '../session'
require_relative '../appio'


class Surface < Command
  def matches? line
    parts = line.split
    return false unless parts.first == "su"
    return true if parts.count == 1
    return false unless parts.count == 2

    # Check if second part is a non-negative integer
    parts[1].match?(/^\d+$/)
  end

  def process line, session
    parts = line.split
    count = parts.count == 2 ? parts[1].to_i : 1

    # Don't do anything if count is 0
    return if count == 0

    # Save current list state
    original_list_was_foreground = (session.list == session.foreground_tasks)

    # Switch to foreground and insert blank line at top first
    session.switch_lists unless session.list == session.foreground_tasks
    session.list.cursor_set(0)
    session.list.insert_blank

    # Switch to background
    session.switch_lists

    # Move up to 'count' random tasks from background to foreground
    # They will be added at position 0, pushing the blank line down
    tasks_moved = 0
    count.times do
      break if session.list.empty?

      # Set cursor to random position
      random_position = rand(session.list.count)
      session.list.cursor_set(random_position)

      # Move task to other list (foreground)
      session.move_task_to_other
      tasks_moved += 1
    end

    # If no tasks were moved, remove the blank line we added
    if tasks_moved == 0
      session.switch_lists unless session.list == session.foreground_tasks
      session.list.cursor_set(0)
      session.list.remove_task_at_cursor
    end

    # Return to original list
    if original_list_was_foreground
      session.switch_lists unless session.list == session.foreground_tasks
    else
      session.switch_lists unless session.list == session.background_tasks
    end
  end

  def description
    CommandDesc.new("su [n]", "surface n random tasks from background to foreground (default 1)")
  end
end
