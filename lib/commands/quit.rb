require_relative '../command'


class Quit < Command

  def description
    CommandDesc.new("q", "save and quit")
  end

  def matches? line
    line.split == ["q"]
  end

  def process line, session
    session.save
    exit
  end

end
