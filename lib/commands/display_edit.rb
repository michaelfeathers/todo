require_relative '../command'
require_relative '../session'


class DisplayEdit < Command

  def description
    CommandDesc.new("ed", "display the task at the cursor with numbered columns")
  end

  def matches?(line)
    line.split == ["ed"]
  end

  def process line, session
    task_line = session.on_list {|list| list.task_at_cursor }
    return if task_line.split.empty?

    session.message_and_wait(message(task_line))
  end

  def message text
    tag, *words = text.split

    task_line   = words.join(' ')
    index_line  = words.map
                       .with_index {|w,i| index_field(i + 1, field_size(w))  }
                       .join

    "#{tag} #{task_line}\n   #{index_line}\n\n"
  end

  def field_size word
    word.size + 1
  end

  def index_field index, size
    index.to_s.ljust(size, ' ')
  end

end
