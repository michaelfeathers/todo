require_relative '../command'
require_relative '../day'
require_relative '../appio'

class SaveToYesterday < Command
  def matches?(line)
     line.split == ["sy"]
   end

   def process(line, session)
     session.on_list do |list|
       return if list.count == 0

       task = list.task_at_cursor
       return if task.strip.empty?

       yesterday = list.io.today.with_fewer_days(1)
       entries   = list.io.read_archive
                          .lines
                          .append("#{yesterday} #{task}\n")
                          .sort_by {|line| line.split.first }

       list.io.write_archive(entries)
       list.remove_task_at_cursor
     end
   end

   def description
     CommandDesc.new("sy", "save task at cursor to archive with yesterday's date")
   end
end
