require_relative 'appio'


class ToDoUpdater

  def initialize io
    @io = io
  end

  def run
    actions = @io.read_actions.lines
    updates = @io.read_updates.lines

    due_updates = due(updates)
    non_due_updates = non_due(updates)

    new_actions = due_updates + actions
    @io.write_actions(new_actions)

    sorted_non_due = non_due_updates.sort_by do |line|
      Day.from_text(line.split.first).date
    end
    @io.write_updates(sorted_non_due)
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
