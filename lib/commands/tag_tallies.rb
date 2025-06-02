require_relative '../command'
require_relative '../session'
require_relative '../appio'

class TagTallies < Command
  def matches? line
    line.split == ["tt"]
  end

  def process line, session
    session.on_list {|list| list.todo_tag_tallies }
  end

  def description
    CommandDesc.new("tt", "show tally of all tag types")
  end
end