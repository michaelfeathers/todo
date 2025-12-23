require_relative '../command'
require_relative '../session'


class CursorToRandom < Command

  def description
    CommandDesc.new("cr", "move cursor to a random task")
  end

  def matches?(line)
    line.split == ["cr"]
  end

  def process(line, session)
    session.on_list do |list|
      return if list.empty?
      random_position = rand(list.count)
      list.cursor_set(random_position)
    end
  end

end
