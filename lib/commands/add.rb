require_relative '../command'
require_relative '../session'
require_relative '../appio'


class Add < Command

  def description
    CommandDesc.new("a  text", "add text as a task")
  end

  def matches? line
    (line.split in ["a", *args]) && args.count >= 0
  end

  def process line, session
    session.add(line.split.drop(1).join(' '))
  end

end
