require_relative 'day'
require_relative 'taskselection'
require_relative 'monthsreport'
require_relative 'appio'
require_relative 'array_ext'


class TaskList

  PAGE_SIZE    = 40
  TAG_PATTERN  = /^[A-Z]:$/

  attr_reader :io, :description

  def initialize io, description = ""
    @io = io
    @tasks = io.read_tasks.lines

    @last_search_text = nil
    @cursor = 0
    @grab_mode = false
    @page_no = 0

    @description = description + $/ + $/
  end

  def empty?
    @tasks.empty?
  end

  def todo_help command_list
    max_length = command_list.map {|cmd| cmd[0].length }.max

    output = command_list.sort_by(&:first)
                         .map {|name, desc| "%-#{max_length + 5}s- %s" % [name, desc] }
                         .join($/)

    @io.append_to_console $/ + "#{output}" + $/ + $/
    @io.get_from_console
  end

  def add task_line
    @tasks = [task_line + $/] + @tasks
    @cursor = 0
    adjust_page
  end

  def save_all
    @io.write_tasks(@tasks)
  end

  def cursor_set line_no
    @cursor = line_no if (0...@tasks.count).include?(line_no)
    adjust_page
  end

  def down
    return if @tasks.count == 0
    return if @cursor >= @tasks.count - 1

    @tasks.swap_elements(@cursor, @cursor + 1) if @grab_mode
    @cursor += 1
    adjust_page
  end

  def up
    return if @tasks.count == 0
    return if @cursor <= 0

    @tasks.swap_elements(@cursor - 1, @cursor) if @grab_mode
    @cursor -= 1
    adjust_page
  end

  def edit_insert position, new_tokens
    current_task = task_at_cursor
    return if current_task.nil? || current_task.empty? || new_tokens.empty?

    task_tokens = current_task.split
    tag = task_tokens.shift if task_tokens.first =~ TAG_PATTERN

    if position > 0 && position <= task_tokens.size + 1
      task_tokens.insert(position - 1, *new_tokens)
      new_task = [tag, task_tokens.join(' ')].compact.join(' ')
      update_task_at_cursor(new_task)
    end
  end

  def todo_find text, limit = nil
    @io.clear_console

    found           = find(text)
    found_to_report = limit ? found.take(limit) : found

    report = "#{found_to_report.join}#{$/}#{found_to_report.count}#{$/}#{$/}#{$/}"
    @io.append_to_console(report)

    @io.get_from_console
  end

  def todo_print_archive
    @io.clear_console
    @io.append_to_console(@io.read_archive)
    @io.get_from_console
  end

  def todo_push days_text
    return if @tasks.count < 1

    updates = @io.read_updates.lines.to_a
    date_text = @io.today.with_more_days(days_text.to_i).to_s

    updates << [date_text, @tasks[@cursor]].join(' ')
    updates = updates.sort_by {|line| DateTime.parse(line.split.first) }

    @io.write_updates(updates)
    remove_task_at_cursor
  end

  def todo_remove
    @io.append_to_console "Remove current line (Y/N)?" + $/
    response = @io.get_from_console

    return unless response.split.first == "Y"

    line = @tasks[@cursor]
    @io.append_to_junk(@io.today.to_s + " " + line) unless line.split.empty?
    remove_task_at_cursor
    @io.write_tasks(@tasks)
  end

  def todo_save
    return if @tasks.count < 1
    return if task_at_cursor.strip.empty?

    @io.append_to_archive(@io.today.to_s + " " + @tasks[@cursor])
    remove_task_at_cursor
  end

  def todo_save_all
    save_all
  end

  def todo_save_no_remove
    return if @tasks.count < 1
    return if task_at_cursor.strip.empty?

    @io.append_to_archive(@io.today.to_s + " " + @tasks[@cursor])
  end

  def todo_show_updates
    @io.clear_console
    @io.append_to_console @io.read_updates
    @io.get_from_console
  end

  def edit text
    return if @tasks.empty?
    new_tokens = text.split

    tag = task_at_cursor.split.first
    return unless tag

    update_task_at_cursor([tag, *new_tokens].join(' '))
  end

  def edit_replace position, new_tokens
    task = task_at_cursor
    return if task.nil?

    tokens = task.split
    if new_tokens.nil? || new_tokens.empty?
      tokens.delete_at(position)
    else
      tokens = replace_tokens(tokens, position, new_tokens)
    end
    update_task_at_cursor(tokens.join(' '))
  end

  def replace_tokens tokens, position, new_tokens
    pre  = tokens.take(position)
    post = tokens.drop(pre.count + new_tokens.count)

    pre + new_tokens + post
  end

  def todo_grab_toggle
    @grab_mode = (not @grab_mode)
  end

  def todo_month_summaries year = nil
    year ||= @io.today.year_no

    MonthsReport.new(@io, year).run
  end

  def todo_today days_prev
    day_to_display = @io.today.with_fewer_days(days_prev.to_i)
    found = @io.read_archive
               .lines
               .select {|line| Day.from_text(line.split.first) === day_to_display }

    @io.append_to_console($/)
    found.each {|line| @io.append_to_console(line) }
    @io.append_to_console($/ + "#{found.count}" + $/ + $/)
    @io.get_from_console
  end

  def todo_trend
      day_frequencies.each {|e| @io.append_to_console(("%3s  %s" %  [e[1], e[0]]) + $/) }
      @io.append_to_console($/)
      @io.get_from_console
  end

  def todo_trend_chart opt_year
    g = Gruff::Line.new(1600)
    g.theme = {
      colors: %w[red],
      marker_color: 'gray',
      font_color: 'black',
      background_colors: 'white'
    }
    g.data('', day_frequencies(opt_year).map {|e| e[1] })
    g.write('trend.png')
    `open trend.png`
  end

  def todo_page_down
    return unless ((@page_no + 1) * PAGE_SIZE) < @tasks.count
    @page_no = @page_no + 1
  end

  def todo_page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def todo_zap_to_position line_no
    clamped_line_no = line_no.clamp(0, @tasks.count - 1)
    @tasks = @tasks.insert(clamped_line_no, @tasks.delete_at(@cursor))
  end

  def todo_retag new_tag
    current_task = @tasks[@cursor]
    return unless current_task

    tokens = current_task.split
    tag_text = "#{new_tag.upcase}:"

    tokens.first =~ TAG_PATTERN ? tokens[0] = tag_text : tokens.unshift(tag_text)
    @tasks[@cursor] = tokens.join(" ") + $/
  end

  def todo_today_target_for month_target
    today = Date.today
    dates = @io.read_archive
               .lines
               .map {|l| DateTime.parse(l.split[0]) }

    current_month_dates = dates.select {|date| date.month == today.month && date.year == today.year }
    tasks_done_prev     = current_month_dates.count {|date| date < today }
    tasks_done_today    = current_month_dates.count(today)
    tasks_done_so_far   = tasks_done_prev + tasks_done_today

    if tasks_done_so_far >= month_target
      @io.append_to_console $/ + $/ + "    Goal met" + $/ + $/
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

    @io.append_to_console "\n\n   Average so far:   %f" % [tasks_done_so_far.to_f / today.day]
    @io.append_to_console   "\n   Average needed:   %f" % [remaining_tasks.to_f / remaining_days]
    @io.append_to_console "\n\n"
    @io.get_from_console
  end

  def window
    @tasks.zip((0..))
          .map {|e, i| [i, cursor_char(i), e] }
          .drop(@page_no * PAGE_SIZE)
          .take(PAGE_SIZE)
  end

  def render
    return if @io.suppress_render_list

    @io.clear_console
    @io.append_to_console @description

    lines = window.map {|num, cursor, line| "%2d %s %s" % [num, cursor, line] }
                  .join

    @io.append_to_console lines + $/
  end

  def adjust_page
    @page_no = @cursor / PAGE_SIZE
  end

  def cursor_char index
    return " " unless @cursor == index
    @grab_mode ? "*" : "-"
  end

  def find text
    @tasks.each_with_index
          .map {|e, i| "%2d %s" % [i, e] }
          .grep(/#{Regexp.escape text}/i)
  end

  def remove_task_at_cursor
    @tasks.delete_at(@cursor)
    @cursor = [@cursor, @tasks.count - 1].min
  end

  def task_at_cursor
    return "" if @tasks.empty?
    @tasks[@cursor].chomp
  end

  def day_frequencies year = nil
    @io.read_archive
       .lines
       .map {|line| line.split.first }
       .select {|d| !year || Day.from_text(d).year ==  year }
       .freq
  end

  def tag_tallies
    @tasks.select {|l| l.strip.length > 0 }
          .map {|l| l.split.first }
          .select {|t| t =~ TAG_PATTERN }
          .freq
  end

  def untagged_tally
    @tasks.select {|l| l.strip.length > 0 }
            .map {|l| l.split.first }
            .reject {|t| t =~ TAG_PATTERN }
            .count
  end

  def todo_tag_tallies
    mask = "   %-10s%3d"
    tagged = tag_tallies.map {|t, n| mask % [t, n] }.join($/)
    untagged = mask % ["Untagged", untagged_tally]

    @io.append_to_console $/ + $/ + "#{tagged}\n\n#{untagged}" + $/ + $/
    @io.get_from_console
  end

  def todo_show_command_frequencies
    data    = @io.read_log
                 .split
                 .map{|line| line.split(',') }
                 .map{|name,count| [name, count.to_i] }

    total   = data.sum {|_,count| count }

    results = data.map {|name, count| "%-5.2f  %-4d   %s" % [count * 100.0 / total, count, name]}
                  .join($/)

    @io.append_to_console $/ + results + $/ + $/
    @io.get_from_console
  end

  def todo_insert_blank
    @tasks.insert(@cursor, $/)
    adjust_page
  end

  def todo_iterative_find_init text
    @last_search_text = text
    found_position = @tasks.index { |task| task =~ /#{Regexp.escape(text)}/i }
    cursor_set(found_position) if found_position
  end

  def todo_iterative_find_continue
    text = @last_search_text
    return unless text

    start_index = [@cursor + 1, @tasks.count - 1].min
    found_position = @tasks[start_index..-1].index { |task| task =~ /#{Regexp.escape(text)}/i }
    found_position += start_index if found_position

    cursor_set(found_position) if found_position
  end

  def todo_zap_to_top
    todo_zap_to_position(0)
  end

  def update_task_at_cursor task_text
    @tasks[@cursor] = task_text + $/
  end

  def count
    @tasks.count
  end

end
