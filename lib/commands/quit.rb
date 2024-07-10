
require_relative '../command'

class Quit < Command

  def matches? line
    line.split == ["q"]
  end

  def process line, session
    session.save
    exit
  end

  def description
    CommandDesc.new("q", "save and quit")
  end
end
