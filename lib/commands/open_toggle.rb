require_relative '../command'
require_relative '../session'


class OpenToggle < Command

  def description
    CommandDesc.new("ot", "open all sections or close them all")
  end

  def matches? line
    line.split == ["ot"]
  end

  def process line, session
    session.on_list {|list| list.sections_toggle_all }
  end

end
