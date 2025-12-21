require_relative '../command'
require_relative '../session'
require_relative '../appio'

class SaveNoRemove < Command
  def matches? line
    line.split == ["ss"]
  end

  def process line, session
    session.on_list do |list|
      return if list.count < 1
      return if list.task_at_cursor.strip.empty?

      io = list.io
      io.append_to_archive(io.today.to_s + " " + list.task_at_cursor + "\n")
    end
  end

  def description
    CommandDesc.new("ss", "save task at cursor without removing")
  end
end