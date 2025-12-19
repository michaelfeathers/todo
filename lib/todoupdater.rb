require_relative 'appio'


class ToDoUpdater

  def initialize io
    @io = io
  end

  def run
    tasks = @io.read_tasks.lines
    updates = @io.read_updates.lines

    due_updates = due(updates)
    non_due_updates = non_due(updates)

    new_tasks = due_updates + tasks
    @io.write_tasks(new_tasks)

    sorted_non_due = non_due_updates.sort_by do |line|
      begin
        Day.from_text(line.split.first).date
      rescue
        # Invalid dates sort to the end
        DateTime.new(9999, 12, 31)
      end
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
    Day.from_text(line.split.first).date <= @io.today.date
  rescue
    false
  end

end
