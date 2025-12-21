require_relative '../command'
require_relative '../session'
require_relative '../appio'


class IterativeFind < Command
  def matches?(line)
    (line.split in ["ff", *args]) && args.count <= 1
  end

  def process(line, session)
    session.on_list do |list|
      tokens = line.split
      if tokens.count > 1
        text = tokens[1]
        list.iterative_find_init(text)
      else
        list.iterative_find_continue
      end
    end
  end

  def description
    CommandDesc.new("ff [text]", "find the first occurrence of text starting from the cursor position (or from the top if text is provided")
  end
end
