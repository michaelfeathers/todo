require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PageDown < Command
  def matches? line
    line.split == ["dd"]
  end

  def process line, session
    session.on_list {|list| list.todo_page_down }
  end

  def description
    CommandDesc.new("dd", "page down")
  end
end