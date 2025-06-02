require_relative '../command'
require_relative '../session'
require_relative '../appio'

class PrintArchive < Command
  def matches?(line)
    line.split == ["pa"]
  end

  def process line, session
    session.on_list {|list| list.todo_print_archive }
  end

  def description
    CommandDesc.new("pa", "print the archive")
  end
end