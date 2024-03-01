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
  TAG_PATTERN  = /^[A-Z]:$/ 

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
    max_length = command_list.map { |cmd| cmd[0].length }.max

    output = command_list.sort_by(&:first)
                         .map { |name, desc| "%-#{max_length + 5}s- %s" % [name, desc] }
                         .join("\n")

    @io.append_to_console "\n#{output}\n\n"
    @io.get_from_console
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

    line = @actions[@cursor] 
    @io.append_to_junk(@io.today.to_s + " " + line) unless line.split.empty?
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
  
  def todo_show_updates
    @io.clear_console
    @io.append_to_console @io.read_updates
    @io.get_from_console
  end

  def todo_edit new_tokens  
    return if @actions.empty?

    old_tokens = @actions[@cursor].split
    @actions[@cursor] = if old_tokens.first =~ TAG_PATTERN 
                          ([old_tokens.first] + new_tokens).join(" ")
                        else
                          new_tokens.join(" ")
                        end + $/
  end

  def todo_grab_toggle
    @grab_mode = (not @grab_mode)
  end
  
  def todo_month_summaries month = nil
    month ||= @io.today.year

    task_descs = @io.read_archive
                    .lines
                    .map {|l| [Day.from_text(l.split[0]), l.split[1].chars.first] }

    year_descs =  task_descs.select {|td| td.first.year.to_i == month.to_i }
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

    tokens.first =~ TAG_PATTERN ? tokens[0] = tag_text : tokens.unshift(tag_text)
    @actions[@cursor] = tokens.join(" ") + $/
  end

  def todo_today_target_for month_target
    today = Date.today
    dates = @io.read_archive
               .lines
               .map {|l| DateTime.parse(l.split[0]) }

    current_month_dates = dates.select { |date| date.month == today.month && date.year == today.year }
    tasks_done_prev     = current_month_dates.count { |date| date < today }
    tasks_done_today    = current_month_dates.count(today)
    tasks_done_so_far   = tasks_done_prev + tasks_done_today 
    
    if tasks_done_so_far >= month_target
      @io.append_to_console "\n\n    Goal met\n\n"
      @io.get_from_console
      return
    end

    last_day_of_month             = Date.new(today.year, today.month, -1)
    remaining_days                = (today..last_day_of_month).count
    remaining_tasks               = month_target - tasks_done_so_far
    daily_tasks_needed            = (remaining_tasks.to_f / remaining_days).ceil

    if remaining_days == 1
      @io.append_to_console "\n\n    Do %d to meet monthly goal of %d\n\n" % [remaining_tasks, month_target]
      @io.get_from_console
      return
    end

    additional_tasks_needed_today = daily_tasks_needed - tasks_done_today
    if additional_tasks_needed_today <= 0
      @io.append_to_console "\n\n    Goal met\n\n"
    else
      @io.append_to_console "\n\n    Do %d to meet daily goal of %d\n\n" % [additional_tasks_needed_today, daily_tasks_needed]
    end
    @io.get_from_console
  end

  def render
    return if @io.suppress_render_list

    @io.clear_console
    @io.append_to_console @description

    lines = @actions.zip((0..))
                    .map { |e, i| "%2d %s %s" % [i, cursor_char(i), e] }
                    .drop(@page_no * PAGE_SIZE).take(PAGE_SIZE)
                    .join

    @io.append_to_console lines + $/
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
    @actions.each_with_index.map {|e,i| "%2d %s" % [i,e] }
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

  def day_frequencies year = nil
    @io.read_archive
       .lines 
       .map {|line| line.split.first }
       .select {|d| !year || Day.from_text(d).year ==  year }
       .freq
  end


  def tag_tallies
    @actions.select {|l| l.strip.length > 0 }
            .map {|l| l.split.first }
            .select {|t| t =~ TAG_PATTERN } 
            .freq
  end

  def untagged_tally
    @actions.select {|l| l.strip.length > 0 }
            .map {|l| l.split.first }
            .reject {|t| t =~ TAG_PATTERN } 
            .count
  end

  def todo_tag_tallies
    mask = "   %-10s%3d" 
    text = tag_tallies.map { |t, n| mask % [t, n] }.join($/)
    untagged = mask % ["Untagged", untagged_tally]

    @io.append_to_console "\n\n#{text}\n\n#{untagged}\n\n"
    @io.get_from_console 
  end

end




