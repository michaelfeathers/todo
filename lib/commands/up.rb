require_relative '../command'
require_relative '../session'


class Up < Command

  def description
    CommandDesc.new("u", "move cursor up")
  end

  def matches? line
    line.split == ["u"]
  end

  def process line, session
    session.on_list {|list| list.up }
  end

end
