require_relative '../command'
require_relative '../session'


class CursorSet < Command

  def description
    CommandDesc.new("c  n|text", "set cursor to line n or section matching text")
  end

  def matches? line
    (line.split in ["c", *args]) && args.count >= 1
  end

  def process line, session
    arg = line.split.drop(1).join(' ')
    session.on_list do |list|
      if arg.match?(/^\d+(\.\d+)?$/)
        list.cursor_set(arg)
      else
        target = list.find_section_by_name(arg)
        list.cursor_set(target) if target
      end
    end
  end

end
