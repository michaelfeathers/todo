
class ConsoleRenderer

  SECTION_PATTERN = /^#(\d+)\s/

  def render list
    list.io.clear_console
    list.io.append_to_console list.description

    lines = list.window.map {|n, c, line| format(n, c, line, list.display_text(line)) }.join

    list.io.append_to_console lines + $/
  end

  private

  def format task_no, cursor, raw_line, display_line
    if raw_line =~ SECTION_PATTERN
      "%4s %s%s %s%s" % [task_no,
                         section_color_start(cursor),
                         cursor,
                         display_line,
                         section_color_end(cursor)]
    else
      indent = task_no.include?('.') ? "  " : ""
      "%4s %s%s %s%s%s" % [task_no,
                         highlight_section_start(cursor),
                         cursor,
                         indent,
                         display_line,
                         highlight_section_end(cursor)]
    end
  end

  def section_color_start cursor
    cursor == ' ' ? "\e[33m" : "\e[33;41m"
  end

  def section_color_end cursor
    "\e[0m"
  end

  def highlight_section_start cursor
    cursor == ' ' ? "" : "\e[41m"
  end

  def highlight_section_end cursor
    cursor == ' ' ? "" : "\e[0m"
  end

end
