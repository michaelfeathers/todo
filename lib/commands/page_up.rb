require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PageUp < Command
  def matches? line
    line.split == ["uu"]
  end

  def process line, session
    session.on_list {|list| list.page_up }
  end

  def description
    CommandDesc.new("uu", "page up")
  end
end