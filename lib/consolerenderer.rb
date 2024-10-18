
class ConsoleRenderer  

  def render list 
    list.io.clear_console
    list.io.append_to_console list.description
  
    lines = list.window.map do |num, cursor, line|
      "%2d %s%s %s%s" % [num, before(cursor), cursor, line, after(cursor)]
    end.join
  
    list.io.append_to_console lines + $/
  end
  
  private
  
  def before(cursor)
    cursor == ' ' ? "" : "\e[41m"
  end
  
  def after(cursor)
    cursor == ' ' ? "" : "\e[0m"
  end

end