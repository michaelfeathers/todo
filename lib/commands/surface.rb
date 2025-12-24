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

    # Switch to foreground and check if blank line already exists at top
    session.switch_lists unless session.list == session.foreground_tasks

    # Check if first task is blank, insert one only if needed
    blank_line_inserted = false
    unless session.list.empty?
      session.list.cursor_set(0)
      first_task = session.list.task_at_cursor
      if first_task.strip.empty?
        # Blank line already exists, don't insert another
        blank_line_inserted = false
      else
        # No blank line, insert one
        session.list.insert_blank
        blank_line_inserted = true
      end
    else
      # Empty list, insert blank line
      session.list.insert_blank
      blank_line_inserted = true
    end

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

    # If no tasks were moved and we inserted a blank line, remove it
    if tasks_moved == 0 && blank_line_inserted
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
