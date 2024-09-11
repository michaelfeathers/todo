require_relative '../command'
require_relative '../session'
require_relative '../appio'


class Help < Command
  def matches? line
    line.split == ["h"]
  end

  def process line, session
    session.on_list do |list|
      list.todo_help(command_descs)
    end
  end

  def command_descs
    ToDo.registered_commands.map {|c| [*c.description] }
  end

  def description
    CommandDesc.new("h", "show help message")
  end
end
