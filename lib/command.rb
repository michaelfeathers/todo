CommandDesc = Struct.new(:name, :line)

class CommandResult
  attr_reader :matches

  def initialize
    @matches = []
  end

  def record_match command
    @matches << command
  end

  def match_count
    @matches.count
  end
end


class Command

  def run line, session, result = CommandResult.new
    return unless matches? line
    result.record_match(self)
    process line, session
  end

  def name
    description.name.split.first
  end

end
