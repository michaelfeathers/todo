
require_relative '../command'
require_relative '../session'

class EditInsert < Command
  def description
    CommandDesc.new("ei position text", "insert text before the specified position in the current task")
  end

  def matches?(line)
    tokens = line.split
    tokens.size >= 3 && tokens[0] == "ei" && tokens[1].match?(/^\d+$/)
  end

  def process(line, session)
    tokens = line.split
    position = tokens[1].to_i
    insert_tokens = tokens[2..-1]

    return if insert_tokens.empty?

    current_task = session.list.action_at_cursor
    return if current_task.nil? || current_task.empty?

    task_tokens = current_task.split
    tag = task_tokens.shift if task_tokens.first =~ TaskList::TAG_PATTERN

    # Only proceed if the position is within bounds (including insertion at the end)
    if position > 0 && position <= task_tokens.size + 1
      task_tokens.insert(position - 1, *insert_tokens)
      new_task = [tag, task_tokens].flatten.compact.join(' ')
      session.list.update_action_at_cursor(new_task)
    end
  end
end
