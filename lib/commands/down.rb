require_relative '../command'
require_relative '../session'


class Down < Command

  def description
    CommandDesc.new("d", "move cursor down")
  end

  def matches? line
    line.split == ["d"]
  end

  def process line, session
    session.on_list {|list| list.down }
  end

end
