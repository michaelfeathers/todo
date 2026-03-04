require_relative '../command'
require_relative '../session'

class AddSection < Command

  def description
    CommandDesc.new("as text", "add a section header")
  end

  def matches? line
    (line.split in ["as", *args]) && args.count >= 1
  end

  def process line, session
    text = line.split.drop(1).join(' ')
    session.on_list {|list| list.add_section(text) }
  end

end
