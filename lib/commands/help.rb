require_relative '../command'
require_relative '../session'
require_relative '../appio'


class Help < Command
  def matches? line
    line.split == ["h"]
  end

  def process line, session
    max_length = command_descs.map {|cmd| cmd[0].length }.max

    output = command_descs.sort_by(&:first)
                          .map {|name, desc| "%-#{max_length + 5}s- %s" % [name, desc] }
                          .join($/)

    session.on_list do |list|
      list.io.append_to_console $/ + "#{output}" + $/ + $/
      list.io.get_from_console
    end

  end

  def command_descs
    ToDo.registered_commands.map {|c| [*c.description] }
  end

  def description
    CommandDesc.new("h", "show help message")
  end
end
