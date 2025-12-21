require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Save < Command
  def matches? line
    line.split == ["s"]
  end

  def process line, session
    session.on_list do |list|
      return if list.count < 1
      return if list.task_at_cursor.strip.empty?

      io = list.io
      io.append_to_archive(io.today.to_s + " " + list.task_at_cursor + "\n")
      list.remove_task_at_cursor
      list.save_all
    end
  end

  def description
    CommandDesc.new("s", "save task at cursor")
  end
end