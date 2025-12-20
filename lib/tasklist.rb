require_relative 'day'
require_relative 'taskselection'
require_relative 'monthsreport'
require_relative 'appio'
require_relative 'array_ext'


class TaskList

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

  def add task_line
    @tasks = [task_line + $/] + @tasks
    @cursor = 0
    adjust_page
  end

  def save_all
    @io.write_tasks(@tasks)
  end

  def cursor_set line_no
    return if @tasks.empty?
    @cursor = line_no.clamp(0, @tasks.count - 1)
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

    if position.between?(1, task_tokens.size + 1)
      task_tokens.insert(position - 1, *new_tokens)
      update_task_at_cursor([tag, task_tokens.join(' ')].compact.join(' '))
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
    @io.display_paginated(@io.read_archive_for_display)
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
    @io.append_to_junk("#{@io.today} #{line}") unless line.strip.empty?
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
    @io.display_paginated(@io.read_updates)
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
    tokens[position, new_tokens.length] = new_tokens unless new_tokens.empty?
    tokens.delete_at(position) if new_tokens.empty?

    update_task_at_cursor(tokens.join(' '))
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
    return unless ((@page_no + 1) * AppIo::PAGE_SIZE) < @tasks.count
    @page_no = @page_no + 1
  end

  def todo_page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def todo_zap_to_position line_no
    return if @tasks.empty?
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

  def todo_target_for month_target
    today = @io.today.date
    dates = @io.read_archive
               .lines
               .reject {|l| l.strip.empty? }
               .map {|l| DateTime.parse(l.split[0]) }

    current_month_dates = dates.select {|date| date.month == today.month && date.year == today.year }
    tasks_done_so_far   = current_month_dates.count

    last_day_of_month = Date.new(today.year, today.month, -1)
    remaining_days    = (today..last_day_of_month).count
    remaining_tasks   = [month_target - tasks_done_so_far, 0].max

    tasks_per_day = remaining_days > 0 ? (remaining_tasks.to_f / remaining_days).ceil : 0

    days_passed = today.day - 1
    daily_average = days_passed > 0 ? (tasks_done_so_far.to_f / days_passed).round(1) : 0.0

    @io.append_to_console "\n\n    Do %d per day to meet monthly goal of %d\n\n    Daily average so far: %.1f\n\n" % [tasks_per_day, month_target, daily_average]
    @io.get_from_console
  end
  
  def window
    @tasks.zip((0..))
          .map {|e, i| [i, cursor_char(i), e] }
          .drop(@page_no * AppIo::PAGE_SIZE)
          .take(AppIo::PAGE_SIZE)
  end

  def adjust_page
    @page_no = @cursor / AppIo::PAGE_SIZE
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
    @cursor = [@cursor, [@tasks.count - 1, 0].max].min
  end

  def task_at_cursor
    return "" if @tasks.empty?
    @tasks[@cursor].chomp
  end

  def todo_tag_tallies
    mask = "   %-10s%3d"
    tagged = tag_tallies.map {|t, n| mask % [t, n] }.join($/)
    untagged = mask % ["Untagged", untagged_tally]

    @io.append_to_console $/ + $/ + "#{tagged}\n\n#{untagged}" + $/ + $/
    @io.get_from_console
  end

  def tag_tallies
    filter_tasks(:select).freq
  end

  def untagged_tally
    filter_tasks(:reject).count
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
    return if @tasks.empty?

    start_index = [@cursor + 1, @tasks.count - 1].min
    found_position = @tasks[start_index..-1].index { |task| task =~ /#{Regexp.escape(text)}/i }
    found_position += start_index if found_position

    cursor_set(found_position) if found_position
  end

  def todo_zap_to_top
    todo_zap_to_position(0)
  end

  def count
    @tasks.count
  end

  private

  def day_frequencies year = nil
    @io.read_archive
       .lines
       .map {|line| line.split.first }
       .select {|d| !year || Day.from_text(d).year ==  year }
       .freq
  end

  def update_task_at_cursor task_text
    @tasks[@cursor] = task_text + $/
  end

  def filter_tasks method
    @tasks.select { |l| l.strip.length > 0 }
          .map { |l| l.split.first }
          .send(method) { |t| t =~ TAG_PATTERN }
  end

end
