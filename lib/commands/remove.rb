require_relative '../command'
require_relative '../session'
require_relative '../appio'

class Remove < Command
  def matches? line
    line.split == ["r"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io

      io.append_to_console "Remove current line (Y/N)?" + $/
      response = io.get_from_console

      return unless response.split.first == "Y"

      task = list.task_at_cursor
      io.append_to_junk("#{io.today} #{task}\n") unless task.strip.empty?
      list.remove_task_at_cursor
      list.save_all
    end
  end

  def description
    CommandDesc.new("r", "remove task at cursor")
  end
end