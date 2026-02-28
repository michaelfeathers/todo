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
    tokens = text.split
    if tokens.first =~ TaskList::TAG_PATTERN
      tag = tokens.shift
      prefix = "#{tag} "
      indent = " " * prefix.length
    else
      prefix = ""
      indent = ""
    end

    task_line   = tokens.join(' ')
    index_line  = tokens.map
                        .with_index {|w,i| index_field(i, field_size(w))  }
                        .join

    "#{prefix}#{task_line}\n#{indent}#{index_line}\n\n"
  end

  def field_size word
    word.size + 1
  end

  def index_field index, size
    index.to_s.ljust(size, ' ')
  end

end
