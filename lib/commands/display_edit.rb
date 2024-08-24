require_relative '../command'
require_relative '../session'


class DisplayEdit < Command

  def description
    CommandDesc.new("ed", "display the task at the cursor with numbered columns")
  end

  def matches?(line)
    line.split == ["ed"]
  end

  def process(line, session)
    io      = session.list.io
    line    = session.list.task_at_cursor

    return if line.split.empty?

    tag, *words = line.split

    task_line = words.join(' ')
    index_line  = words.map
                       .with_index {|w,i| index_field(i + 1, field_size(w))  }
                       .join

   io.append_to_console "#{tag} #{task_line}\n   #{index_line}\n\n"
   io.get_from_console
  end

  def field_size word
    word.size + 1
  end

  def index_field index, size
    index.to_s.ljust(size, ' ')
  end

end
