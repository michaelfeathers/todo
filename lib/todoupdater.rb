$:.unshift File.dirname(__FILE__)

require 'common'
require 'appio'


class ToDoUpdater
  def run
    [[lines_of(TODO_FILE), lines_of(UPDATER_FILE)]]
      .map {|ts,us| [due(us) + ts, non_due(us)] }
      .each  do |ts,us| 
        write_lines(TODO_FILE, ts)
        write_lines(UPDATER_FILE, us.sort_by {|lines| DateTime.parse(lines.split.first)})
      end
  end

  def due us
    us.select {|e| due?(e)}
      .map {|e| strip_date(e)} 
  end

  def non_due us
     us.reject {|e| due?(e)}
  end

  def lines_of file_name
    File.read(file_name).lines
  end

  def write_lines file_name, lines
    File.open(file_name, 'w') { |f| f.write(lines.join) }
  end

  def strip_date line
    line.split.drop(1).join(" ") + $/
  end

  def due? line 
    tokens = line.split
    return false unless tokens.size > 0
    day_date(DateTime.parse(tokens.first)) <= day_date(DateTime.now)
  rescue
    false
  end
end




