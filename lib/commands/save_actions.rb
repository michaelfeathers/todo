require_relative '../command'
require_relative '../session'
require_relative '../appio'

class SaveActions < Command
  def matches?(line)
    line.split == ["@"]
  end

  def process(line, session)
    session.save
  end

  def description
    CommandDesc.new("@", "save the tasks without quitting")
  end
end