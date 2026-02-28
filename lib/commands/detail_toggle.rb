require_relative '../command'
require_relative '../session'
require_relative '../appio'


class DetailToggle < Command
  def matches? line
    line.split == ["~"]
  end

  def process line, session
    session.on_list {|list| list.detail_toggle }
  end

  def description
    CommandDesc.new("~", "toggle display of tags")
  end
end
