$:.unshift File.dirname(__FILE__)

require 'day'
require 'appio'
require 'array_ext'

=begin
require 'gruff' 
=end


def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end


class TaskList

  PAGE_SIZE    = 40
  TAG_PATTERN  =  /^[A-Z]:\s+/ 

   attr_reader :io, :description

  def initialize io, description = ""
    @io = io
    @actions = io.read_actions.lines
    @cursor = 0
    @grab_mode = false
    @page_no = 0

    @description = description + $/ + $/
  end

  def todo_help command_list
     max = command_list.map {|cmd| cmd[0].length }.max

     output = command_list.sort_by {|n,_| n }
                          .map {|n, l| "#{n.ljust(max + 5)}- #{l}" }
                          .join("\n") 
     
     @io.append_to_console $/ + output + $/ + $/ 
  end


  def todo_add tokens
    @actions = [tokens.join(" ") + $/] + @actions
    @cursor = 0
    adjust_page
  end

  def save_all
    @io.write_actions(@actions)
  end

  def todo_cursor_set line_no
    @cursor = line_no if (0...@actions.count).include?(line_no)
    adjust_page
  end

  def todo_down
    return unless @actions.count > 1 && @cursor < @actions.count - 1
    
    @actions.swap_elements(@cursor, @cursor + 1) if @grab_mode
    @cursor += 1
    adjust_page
  end

  def todo_up
    return unless @actions.count > 1 && @cursor > 0

    @actions.swap_elements(@cursor - 1, @cursor) if @grab_mode
    @cursor -= 1
    adjust_page
  end

  def todo_find text
    @io.clear_console

    found = find(text) 
    @io.append_to_console found.join + $/ + found.count.to_s + $/ + $/ + $/
  end
  
  def todo_push days_text
    return if @actions.count < 1

    updates = @io.read_updates.lines.to_a
    date_text = @io.today.with_more_days(days_text.to_i).to_s

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
    return if @actions.count < 1
    @io.append_to_archive(@io.today.to_s + " " + @actions[@cursor])  
    remove_action_at_cursor
  end

  def todo_save_no_remove
    return if @actions.count < 1
    @io.append_to_archive(@io.today.to_s + " " + @actions[@cursor]) 
  end

  def todo_edit new_tokens  
    return if @actions.empty?

    old_tokens = @actions[@cursor].split
    @actions[@cursor] = if old_tokens.first =~ /^[A-Z]*:$/
                          ([old_tokens.first] + new_tokens).join(" ")
                        else
                          new_tokens.join(" ")
                        end + $/
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
                                                       count_month_entries(month, "*", year_descs)]

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

  def todo_today days_prev
    day_to_display = @io.today.with_fewer_days(days_prev.to_i) 
    @io.read_archive
       .lines 
       .select {|line| Day.from_text(line.split.first) === day_to_display }
       .each {|line| @io.append_to_console(line) }
    @io.append_to_console($/)
    @io.get_from_console
  end

  def todo_trend
      day_frequencies.each {|e| @io.append_to_console(("%3s  %s" %  [e[1], e[0]]) + $/) } 
      @io.append_to_console($/)
      @io.get_from_console
  end

=begin
  def todo_trend_chart
    g = Gruff::Line.new(1600)
    g.theme = {
      colors: %w[red],
      marker_color: 'gray',
      font_color: 'black',
      background_colors: 'white'
    }
    g.data('', day_frequencies.map {|e| e[1] })  
    g.write('trend.png')
    `open trend.png`
  end
=end

  def todo_page_down
    return unless ((@page_no + 1) * PAGE_SIZE) < @actions.count
    @page_no = @page_no + 1
  end

  def todo_page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def todo_zap_to_position line_no
    line_no = [[0, line_no].max, @actions.count-1].min
    @actions = @actions.insert(line_no, @actions.delete_at(@cursor))
  end               

  def todo_surface no_elements
    surface(no_elements)
  end

  def todo_retag new_tag
    current_action = @actions[@cursor]
    return unless current_action
   
    tokens = current_action.split
    tag_text = "#{new_tag.upcase}:"

    tokens.first =~ /^[A-Z]*:$/ ? tokens[0] = tag_text : tokens.unshift(tag_text)
    @actions[@cursor] = tokens.join(" ") + $/
  end
  

  def render
    @io.clear_console
    @io.append_to_console @description + $/
     
    lines = @actions.zip((0..))
                    .map {|e,i| "%2d %s %s" % [i, cursor_char(i), e]}
                    .drop(@page_no * PAGE_SIZE)
                    .take(PAGE_SIZE)

    @io.append_to_console lines.join + $/
  end

  def count_month_entries month_no, type, descs
    return descs.select {|d| d.first.month_no == month_no }.count if type == "*"

    descs.select {|d| d.first.month_no == month_no }
         .select {|dd| dd[1] == type }
         .count
  end

  def adjust_page
    @page_no = @cursor / PAGE_SIZE
  end

  def cursor_char index
    return " " unless @cursor == index
    @grab_mode ? "*" : "-"
  end

  def find text
    @actions.each_with_index.map {|i,e| "%2d %s" % [e,i] }
            .grep(/#{Regexp.escape text}/i)
  end

  def remove_action_at_cursor
    @actions.delete_at(@cursor)
    @cursor = [@cursor, @actions.count - 1].min
  end

  def action_at_cursor
    @actions[@cursor]
  end

  def surface count
    return if @actions.count < 2 

    count.times do 
      todo_cursor_set(@actions.count - 1)
      todo_zap_to_position(0)
    end

    todo_cursor_set(0)
  end

  def day_frequencies
    @io.read_archive
       .lines 
       .map {|line| line.split.first }
       .freq
  end

  def tag_tallies 
    @actions.grep(TAG_PATTERN) {|l| l.split.first}
            .freq
  end

  def untagged_tally
    @actions.grep_v(TAG_PATTERN).count {|l| not l.strip.empty? } 
  end

  def todo_tag_tallies
    text = tag_tallies.map {|t,n| "   %-10s%3d" % [t, n] }
                      .join($/)

    untagged_count = untagged_tally

    @io.append_to_console $/ + $/ + text + $/
    @io.append_to_console $/ + ("   %-10s%3d" % ["Untagged", untagged_count]) + $/ + $/
 
    @io.get_from_console 
  end

end




