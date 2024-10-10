
require_relative '../command'
require_relative '../session'


class EditInsert < Command

  def description
    CommandDesc.new("ei position text", "insert text before the specified position in the current task")
  end

  def matches?(line)
    (line.split in ["ei", *args]) && args.count >= 2 && args[0].match?(/^\d+$/)
  end

  def process(line, session)
    tokens = line.split
    position = tokens[1].to_i
    insert_tokens = tokens[2..-1]

    session.on_list {|list| list.edit_insert(position, insert_tokens) }
  end

end
