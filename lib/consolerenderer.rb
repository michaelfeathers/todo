
class ConsoleRenderer  

  def render list 
    list.io.clear_console
    list.io.append_to_console list.description
  
    lines = list.window.map {|fields| format(*fields) }.join
  
    list.io.append_to_console lines + $/
  end
  
  private

  def format task_no, cursor, line
    "%2d %s%s %s%s" % [task_no, 
                       highlight_section_start(cursor), 
                       cursor, 
                       line, 
                       highlight_section_end(cursor)]
  end
  
  def highlight_section_start cursor
    cursor == ' ' ? "" : "\e[41m"
  end
  
  def highlight_section_end cursor
    cursor == ' ' ? "" : "\e[0m"
  end

end