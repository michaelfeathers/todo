require_relative 'appio'


class ToDoUpdater

  def initialize io
    @io = io
  end

  def run
    [[@io.read_actions.lines, @io.read_updates.lines]]
      .map {|ts,us| [due(us) + ts, non_due(us)] }
      .each  do |ts,us|
        @io.write_actions(ts)
        @io.write_updates(us.sort_by {|lines| Day.from_text(lines.split.first).date})
      end
  end

  def due us
    us.select {|e| due?(e)}
      .map {|e| strip_date(e)}
  end

  def non_due us
     us.reject {|e| due?(e)}
  end

  def strip_date line
    line.split.drop(1).join(" ") + $/
  end

  def due? line
    tokens = line.split
    return false unless tokens.any?
    Day.from_text(tokens.first).date <= @io.today.date
  rescue
    false
  end

end
