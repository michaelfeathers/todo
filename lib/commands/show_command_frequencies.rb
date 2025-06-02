require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ShowCommandFrequencies < Command
  def matches? line
    line.split == ["sf"]
  end

  def process line, session
    session.on_list {|list| list.todo_show_command_frequencies }
  end

  def description
    CommandDesc.new("sf ", "show command frequencies")
  end
end