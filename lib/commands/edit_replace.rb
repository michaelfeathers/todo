
require_relative '../command'
require_relative '../session'


class EditReplace < Command

  def description
    CommandDesc.new("er position [token...]", "replace token(s) starting at pos with replacement token(s). Delete token at pos if none.")
  end

  def matches? line
    (line.split in ["er", *args]) && args.count >= 1
  end

  def process line, session
    tokens = line.split
    position = tokens[1].to_i
    new_tokens = tokens.drop(2)

    session.list.edit_replace(position, new_tokens)
  end

end
