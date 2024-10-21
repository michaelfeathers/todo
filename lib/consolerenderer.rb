
class ConsoleRenderer  

  def render list 
    list.io.clear_console
    list.io.append_to_console list.description
  
    lines = list.window.map do |num, cursor, line|
      "%2d %s%s %s%s" % [num, highlight_on(cursor), cursor, line, highlight_off(cursor)]
    end.join
  
    list.io.append_to_console lines + $/
  end
  
  private
  
  def highlight_on cursor
    cursor == ' ' ? "" : "\e[41m"
  end
  
  def highlight_off cursor
    cursor == ' ' ? "" : "\e[0m"
  end

end