$:.unshift File.dirname(__FILE__)

require 'day'
require 'appio'
require 'array_ext'


def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end


class Session

  VIEW_LIMIT   = 45
  PAGE_SIZE    = 40

  def initialize io
    @io = io
    @actions = io.read_actions.lines
    @cursor = 0
    @grab_mode = false
    @page_no = 0
  end

  def todo_add tokens
    @actions = [tokens.join(" ") + $/] + @actions
    @cursor = 0
  end

  def todo_quit
    @io.write_actions(@actions)
    exit
  end

  def todo_cursor_set line_no
    @cursor = line_no if (0...@actions.count).include?(line_no)
  end

  def todo_down
    return unless @actions.count > 1 
    return unless @cursor < @actions.count - 1
    
    @actions.swap_elements(@cursor, @cursor + 1) if @grab_mode
    @cursor += 1
  end

  def todo_up
    return unless @actions.count > 1
    return unless @cursor > 0

    @actions.swap_elements(@cursor - 1, @cursor) if @grab_mode
    @cursor -= 1
  end

  def todo_find text
    @io.clear_console
    found = find(text) 
    @io.append_to_console found.join + $/ + found.count.to_s + $/ + $/ + $/
  end
  
  def todo_push days_text
    updates = @io.read_updates.lines.to_a
    date_text = Day.new(DateTime.now.next_day(days_text.to_i)).to_s

    updates << [date_text, @actions[@cursor]].join(' ')
    updates = updates.sort_by {|line| DateTime.parse(line.split.first) }

    @io.write_updates(updates)
    remove_action_at_cursor
  end

  def todo_remove
    @io.append_to_console "Remove current line (Y/N)?\n"
    response = @io.get_from_console
    return unless response.split.first == "Y"

    remove_action_at_cursor
    @io.write_actions(@actions)
  end

  def todo_save
    @io.append_to_archive(@io.today.to_s + " " + @actions[@cursor])  
    remove_action_at_cursor
  end

  def todo_save_no_remove
    @io.append_to_archive(@io.today.to_s + " " + @actions[@cursor]) 
  end

  def todo_edit tokens
    @actions[@cursor] = tokens.join(" ") + $/
  end

  def todo_grab_toggle
    @grab_mode = (not @grab_mode)
  end
  
  def todo_month_summaries 
    task_descs = @io.read_archive
                    .lines
                    .map {|l| [Day.from_text(l.split[0]), l.split[1].chars.first] }

    year_descs =  task_descs.select {|td| td.first.year.to_i == 2023 }
      @io.append_to_console "\n\n      %10s %10s %10s\n\n" % ["R7K", "Life", "Total"]

     (1..12).each do |month|
      @io.append_to_console "%s   %10d %10d %10d\n" % [month_name_of(month), 
                                                       count_month_entries(month, "R", year_descs),
                                                       count_month_entries(month, "L", year_descs),
                                                       count_month_entries(month, "*",  year_descs)]

    end

    @io.append_to_console $/
    @io.append_to_console "      %10d %10d %10d\n" % [year_descs.select {|dd| dd[1] == "R" }.count,
                                                      year_descs.select {|dd| dd[1] == "L" }.count,
                                                      year_descs.count]

    @io.append_to_console $/

    todays = year_descs.select {|d| d.first === Day.today } 

    if todays.count > 0
      @io.append_to_console "Today %10d %10d %10d\n" % [todays.select {|d| d[1] == "R" }.count,
                                         todays.select {|d| d[1] == "L" }.count,
                                         todays.count]
    else
      @io.append_to_console "Today %10d %10d %10d\n" % [0, 0, 0]
    end

    @io.append_to_console $/
    @io.append_to_console $/

    @io.get_from_console

  end

  def todo_today
    @io.read_archive
       .lines 
       .select {|line| Day.from_text(line.split.first) === @io.today }
       .each { |line| @io.append_to_console(line) }
    @io.append_to_console($/)
    @io.get_from_console
  end

  def todo_trend
      @io.read_archive
         .lines 
         .map {|line| line.split[0] }
         .freq
         .each {|e| @io.append_to_console(("%3s  %s" %  [e[1], e[0]]) + $/) } 
      @io.append_to_console($/)
      @io.get_from_console
  end

  def todo_page_down
    return unless ((@page_no + 1) * PAGE_SIZE) < @actions.count
    @page_no = @page_no + 1
  end

  def todo_page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def todo_zap_to_position line_no
    line_no = [line_no, @actions.count-1].min
    line_no = [0, line_no].max

    @actions = @actions.insert(line_no, @actions.delete_at(@cursor))
  end               

  def render
    @io.clear_console

    lines = @actions.zip((0..))
                    .map {|e,i| "%2d %s %s" % [i, cursor_char(i), e]}
                    .drop(@page_no * PAGE_SIZE)
                    .take(VIEW_LIMIT)

    @io.append_to_console lines.join + $/
  end

  def count_month_entries month_no, type, descs
    return  descs.select {|d| d.first.month_no == month_no }.count if type == "*"
    descs.select {|d| d.first.month_no == month_no }.select {|dd| dd[1] == type }.count
  end

  def cursor_char index
    return " " unless @cursor == index
    @grab_mode ? "*" : "-"
  end

  def find text
    @actions.each_with_index.map {|i,e| "%2d %s" % [e,i] }.grep(/#{Regexp.escape text}/i)
  end

  def remove_action_at_cursor
    @actions.delete_at(@cursor)
    @cursor = [@cursor, @actions.count - 1].min
  end

  def surface count
    return if @actions.count < 2 
    count.times do 
      todo_cursor_set(@actions.count - 1)
      todo_zap_to_position(0)
    end
    todo_cursor_set(0)
  end

end




