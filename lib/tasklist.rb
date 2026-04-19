require_relative 'day'
require_relative 'taskselection'
require_relative 'monthsreport'
require_relative 'appio'
require_relative 'interactive_paginator'
require_relative 'array_ext'
require_relative 'task'
require_relative 'section'


class TaskList

  TAG_PATTERN  = /^[A-Z]:$/
  SECTION_PATTERN = /^#(\d+)\s/

  attr_reader :io, :description

  def initialize io, description = ""
    @io = io
    @items = parse_items(io.read_tasks.lines)

    @last_search_text = nil
    @cursor = [0, nil]
    @grab_mode = false
    @detail_mode = false
    @page_no = 0

    @description = description + $/ + $/
  end

  def empty?
    @items.empty?
  end

  def add task_line
    @items.unshift(Task.new(task_line + $/))
    @cursor = [0, nil]
    adjust_page
  end

  def add_section text
    @items.unshift(Section.new(text))
    @cursor = [0, nil]
    adjust_page
  end

  def save_all
    lines = @items.flat_map do |item|
      if item.section?
        [item.text] + item.children.map(&:text)
      else
        [item.text]
      end
    end
    @io.write_tasks(lines)
  end

  def cursor_set line_no
    return if @items.empty?
    if line_no.is_a?(String)
      if line_no.include?('.')
        parts = line_no.split('.')
        top = parts[0].to_i
        child = parts[1].to_i - 1
        return unless top >= 0 && top < @items.size
        return unless @items[top].section?
        return unless child >= 0 && child < @items[top].children.size
        @items[top].collapsed = false
        @cursor = [top, child]
      else
        top = line_no.to_i.clamp(0, @items.size - 1)
        @cursor = [top, nil]
      end
    else
      @cursor = [line_no.clamp(0, @items.size - 1), nil]
    end
    adjust_page
  end

  def down
    return if @items.empty?
    top, child = @cursor

    if @grab_mode
      grab_down
    else
      item = @items[top]
      if child.nil?
        if item.section? && !item.collapsed && item.children.any?
          @cursor = [top, 0]
        elsif top < @items.size - 1
          @cursor = [top + 1, nil]
        end
      else
        if child < item.children.size - 1
          @cursor = [top, child + 1]
        elsif top < @items.size - 1
          @cursor = [top + 1, nil]
        end
      end
      adjust_page
    end
  end

  def up
    return if @items.empty?
    top, child = @cursor

    if @grab_mode
      grab_up
    else
      if child.nil?
        return if top <= 0
        prev_item = @items[top - 1]
        if prev_item.section? && !prev_item.collapsed && prev_item.children.any?
          @cursor = [top - 1, prev_item.children.size - 1]
        else
          @cursor = [top - 1, nil]
        end
      else
        if child > 0
          @cursor = [top, child - 1]
        else
          @cursor = [top, nil]
        end
      end
      adjust_page
    end
  end

  def edit_insert position, new_tokens
    current_task = task_at_cursor
    return if current_task.nil? || current_task.empty? || new_tokens.empty?

    task_tokens = current_task.split
    tag = task_tokens.shift if task_tokens.first =~ TAG_PATTERN

    return if position < 0

    insert_position = [position, task_tokens.size].min
    task_tokens.insert(insert_position, *new_tokens)
    update_task_at_cursor([tag, task_tokens.join(' ')].compact.join(' '))
  end

  def edit text
    return if @items.empty?
    new_tokens = text.split

    tag = task_at_cursor.split.first
    return unless tag

    update_task_at_cursor([tag, *new_tokens].join(' '))
  end

  def edit_replace position, new_tokens
    task = task_at_cursor
    return if task.nil?

    tokens = task.split
    tag = tokens.shift if tokens.first =~ TAG_PATTERN

    if new_tokens.empty?
      tokens.delete_at(position)
    elsif position >= tokens.size
      tokens.concat(new_tokens)
    else
      tokens[position, new_tokens.length] = new_tokens
    end

    update_task_at_cursor([tag, tokens.join(' ')].compact.join(' '))
  end

  def grab_toggle
    @grab_mode = (not @grab_mode)
  end

  def detail_toggle
    @detail_mode = !@detail_mode
  end

  def page_down
    return unless ((@page_no + 1) * InteractivePaginator::PAGE_SIZE) < visible_count
    @page_no = @page_no + 1
  end

  def page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def zap_to_position line_no
    return if @items.empty?

    if line_no.is_a?(String)
      return if line_no.include?('.')
      target = line_no.to_i
    else
      target = line_no
    end

    top, child = @cursor

    if child
      task = @items[top].remove(child)
      target = target.clamp(0, @items.size)
      @items.insert(target, task)
      # Fix cursor in section after child removal
      if @items[top].section? && @items[top].children.any?
        @cursor = [top, [child, @items[top].children.size - 1].min]
      else
        @cursor = [top, nil]
      end
    elsif cursor_on_section_header?
      section = @items.delete_at(top)
      target = target.clamp(0, [@items.size, 0].max)
      @items.insert(target, section)
      @cursor = [target, nil]
    else
      task = @items.delete_at(top)
      target = target.clamp(0, [@items.size, 0].max)
      @items.insert(target, task)
      # Cursor stays at same index (old behavior)
    end
  end

  def retag new_tag
    item = cursor_item
    return unless item

    tokens = item.text.split
    tag_text = "#{new_tag.upcase}:"

    tokens.first =~ TAG_PATTERN ? tokens[0] = tag_text : tokens.unshift(tag_text)
    item.text = tokens.join(" ") + $/
  end

  def window
    visible_items = []
    @items.each_with_index do |item, i|
      visible_items << [display_label(i), cursor_char(i, nil), item.text]
      if item.section? && !item.collapsed
        item.children.each_with_index do |child, j|
          visible_items << [display_label(i, j), cursor_char(i, j), child.text]
        end
      end
    end
    visible_items.drop(@page_no * InteractivePaginator::PAGE_SIZE)
                 .take(InteractivePaginator::PAGE_SIZE)
  end

  def find text
    results = []
    @items.each_with_index do |item, i|
      results << "%4s %s" % [display_label(i), item.text]
      if item.section?
        item.children.each_with_index do |child, j|
          results << "%4s %s" % [display_label(i, j), child.text]
        end
      end
    end
    results.grep(/#{Regexp.escape text}/i)
  end

  def remove_task_at_cursor
    top, child = @cursor
    if child
      @items[top].remove(child)
      if @items[top].children.empty?
        @cursor = [top, nil]
      elsif child >= @items[top].children.size
        @cursor = [top, @items[top].children.size - 1]
      end
    elsif cursor_on_section_header?
      section = @items.delete_at(top)
      section.children.reverse.each { |c| @items.insert(top, c) }
      clamp_cursor
    else
      @items.delete_at(top)
      clamp_cursor
    end
  end

  def task_at_cursor
    return "" if @items.empty?
    item = cursor_item
    return "" unless item
    item.text.chomp
  end

  def tag_tallies
    filter_tasks(:select).freq
  end

  def untagged_tally
    filter_tasks(:reject).count
  end

  def insert_blank
    @items.insert(@cursor[0], Task.new($/))
    @cursor = [@cursor[0], nil]
    adjust_page
  end

  def iterative_find_init text
    @last_search_text = text
    positions = all_positions
    found = positions.find { |pos| item_at(*pos).text =~ /#{Regexp.escape(text)}/i }
    if found
      @cursor = found
      adjust_page
    end
  end

  def iterative_find_continue
    text = @last_search_text
    return unless text
    return if @items.empty?

    positions = all_positions
    current_idx = positions.index(@cursor) || 0
    start_idx = [current_idx + 1, positions.size - 1].min

    remaining = positions[start_idx..]
    found = remaining.find { |pos| item_at(*pos).text =~ /#{Regexp.escape(text)}/i }
    if found
      @cursor = found
      adjust_page
    end
  end

  def zap_to_top
    zap_to_position(0)
  end

  def count
    @items.size
  end

  def display_text task
    if task =~ SECTION_PATTERN
      text_after = task.sub(SECTION_PATTERN, '').strip
      return text_after + $/
    end

    tokens = task.split
    has_tag = tokens.first =~ TAG_PATTERN
    if @detail_mode
      has_tag ? task : "   " + task
    else
      has_tag && tokens.size > 1 ? tokens.drop(1).join(' ') + $/ : task
    end
  end

  # Section query methods

  def find_section_by_name(text)
    @items.each_with_index do |item, i|
      next unless item.section?
      return i if item.name.downcase.start_with?(text.downcase)
    end
    nil
  end

  def section_header?(top_index)
    return false if top_index < 0 || top_index >= @items.size
    @items[top_index].section?
  end

  def section_declared_count(top_index)
    return 0 unless section_header?(top_index)
    @items[top_index].children.size
  end

  def section_actual_count(top_index)
    section_declared_count(top_index)
  end

  def section_range(top_index)
    return top_index..top_index unless section_header?(top_index)
    top_index..(top_index + @items[top_index].children.size)
  end

  def cursor_on_section_header?
    return false if @items.empty?
    @cursor[1].nil? && @items[@cursor[0]]&.section?
  end

  def display_label(top_index, child_index = nil)
    child_index ? "#{top_index}.#{child_index + 1}" : top_index.to_s
  end

  # Section mutation methods

  def section_toggle
    return unless cursor_on_section_header?
    item = @items[@cursor[0]]
    item.collapsed = !item.collapsed
  end

  def sections_toggle_all
    sections = @items.select(&:section?)
    return if sections.empty?
    target = sections.any?(&:collapsed)
    sections.each { |s| s.collapsed = !target }
  end

  def section_insert(target_top_index)
    return if cursor_on_section_header?
    return unless @items[target_top_index]&.section?

    top, child = @cursor

    if child
      task = @items[top].remove(child)
      @items[target_top_index].add(task)
    else
      return if top == target_top_index
      task = @items.delete_at(top)
      adjusted = top < target_top_index ? target_top_index - 1 : target_top_index
      @items[adjusted].add(task)
      target_top_index = adjusted
    end

    @items[target_top_index].collapsed = false
    @cursor = [target_top_index, @items[target_top_index].children.size - 1]
    adjust_page
  end

  private

  def parse_items(lines)
    items = []
    i = 0
    while i < lines.size
      if lines[i] =~ /^#(\d+)\s(.+)/
        count = $1.to_i
        name = $2.strip
        section = Section.new(name)
        consumed = 0
        while consumed < count && (i + 1) < lines.size && lines[i + 1] !~ /^#\d+\s/
          i += 1
          section.add(Task.new(lines[i]))
          consumed += 1
        end
        items << section
      else
        items << Task.new(lines[i])
      end
      i += 1
    end
    items
  end

  def cursor_item
    top, child = @cursor
    return nil if top >= @items.size
    item = @items[top]
    child ? item.children[child] : item
  end

  def item_at(top, child)
    child ? @items[top].children[child] : @items[top]
  end

  def all_positions
    positions = []
    @items.each_with_index do |item, i|
      positions << [i, nil]
      if item.section?
        item.children.each_with_index { |_, j| positions << [i, j] }
      end
    end
    positions
  end

  def visible_positions
    positions = []
    @items.each_with_index do |item, i|
      positions << [i, nil]
      if item.section? && !item.collapsed
        item.children.each_with_index { |_, j| positions << [i, j] }
      end
    end
    positions
  end

  def visible_count
    @items.sum do |item|
      if item.section? && !item.collapsed
        1 + item.children.size
      else
        1
      end
    end
  end

  def adjust_page
    positions = visible_positions
    idx = positions.index(@cursor) || 0
    @page_no = idx / InteractivePaginator::PAGE_SIZE
  end

  def cursor_char(top, child)
    return " " unless @cursor == [top, child]
    @grab_mode ? "*" : "-"
  end

  def update_task_at_cursor task_text
    item = cursor_item
    return unless item
    item.text = task_text + $/
  end

  def clamp_cursor
    if @items.empty?
      @cursor = [0, nil]
    else
      @cursor = [[@cursor[0], @items.size - 1].min, nil]
    end
  end

  def grab_down
    top, child = @cursor
    if child
      item = @items[top]
      if child < item.children.size - 1
        item.children.swap_elements(child, child + 1)
        @cursor = [top, child + 1]
      end
    else
      return if top >= @items.size - 1
      @items.swap_elements(top, top + 1)
      @cursor = [top + 1, nil]
    end
    adjust_page
  end

  def grab_up
    top, child = @cursor
    if child
      if child > 0
        @items[top].children.swap_elements(child, child - 1)
        @cursor = [top, child - 1]
      end
    else
      return if top <= 0
      @items.swap_elements(top, top - 1)
      @cursor = [top - 1, nil]
    end
    adjust_page
  end

  def filter_tasks method
    all_texts
      .select { |t| t.strip.length > 0 }
      .map { |t| t.split.first }
      .send(method) { |t| t =~ TAG_PATTERN }
  end

  def all_texts
    @items.flat_map do |item|
      if item.section?
        [item.text] + item.children.map(&:text)
      else
        [item.text]
      end
    end
  end

end
