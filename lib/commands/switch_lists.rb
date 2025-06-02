require_relative '../command'
require_relative '../session'
require_relative '../appio'

class SwitchLists < Command
  def matches? line
    (line.split in ["w", *args]) && (args.count == 0 || (args.count == 1 && args[0] =~ /^\d+$/))
  end

  def process line, session
    target_position = nil
    tokens = line.split

    target_position = tokens[1].to_i if tokens.count == 2

    session.switch_lists(target_position)
  end

  def description
    CommandDesc.new("w [n]", "switch foreground and background lists, optionally moving cursor to position n")
  end
end