require_relative 'day'
require_relative 'taskselection'
require_relative 'monthsreport'
require_relative 'appio'
require_relative 'interactive_paginator'
require_relative 'array_ext'
require_relative 'task'
require_relative 'section'
require_relative 'position'


class TaskList

  TAG_PATTERN  = /^[A-Z]:$/
  SECTION_PATTERN = /^#(\d+)\s/

  attr_reader :io, :description

  def initialize io, description = ""
    @io = io
    @items = parse_items(io.read_tasks.lines)

    @last_search_text = nil
    @cursor = Position.top(0)
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
    @cursor = Position.top(0)
    adjust_page
  end

  def add_section text
    @items.unshift(Section.new(text))
    @cursor = Position.top(0)
    adjust_page
  end

  def save_all
    @io.write_tasks(all_texts)
  end

  def cursor_set line_no
    return if @items.empty?
    pos = parse_position(line_no)
    return unless pos
    @items[pos.top].collapsed = false if pos.child?
    @cursor = pos
    adjust_page
  end

  def down
    return if @items.empty?
    return grab_down if @grab_mode
    step(+1)
  end

  def up
    return if @items.empty?
    return grab_up if @grab_mode
    step(-1)
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

  def more_below?
    ((@page_no + 1) * InteractivePaginator::PAGE_SIZE) < visible_count
  end

  def page_up
    return unless @page_no > 0
    @page_no = @page_no - 1
  end

  def zap_to_position line_no
    return if @items.empty?
    target = zap_target(line_no)
    return unless target

    if @cursor.child?
      task = @items[@cursor.top].remove(@cursor.child)
      @items.insert(target.clamp(0, @items.size), task)
      @cursor = cursor_after_child_removal(@cursor)
    else
      item = @items.delete_at(@cursor.top)
      target = target.clamp(0, @items.size)
      @items.insert(target, item)
      # A whole section moves with the cursor; a bare task leaves the cursor put.
      @cursor = Position.top(target) if item.section?
    end
  end

  def retag new_tag
    item = @cursor.resolve(@items)
    return unless item

    tokens = item.text.split
    tag_text = "#{new_tag.upcase}:"

    tokens.first =~ TAG_PATTERN ? tokens[0] = tag_text : tokens.unshift(tag_text)
    item.text = tokens.join(" ") + $/
  end

  def window
    visible_positions.map { |pos| [pos.label, cursor_char(pos), pos.resolve(@items).text] }
                     .drop(@page_no * InteractivePaginator::PAGE_SIZE)
                     .take(InteractivePaginator::PAGE_SIZE)
  end

  def find text
    all_positions.map { |pos| "%4s %s" % [pos.label, pos.resolve(@items).text] }
                 .grep(/#{Regexp.escape text}/i)
  end

  def remove_task_at_cursor
    return clamp_cursor if @items.empty?
    if @cursor.child?
      @items[@cursor.top].remove(@cursor.child)
      @cursor = cursor_after_child_removal(@cursor)
    else
      # Removing a section header spills its children back into the list;
      # a bare task has no children, so this is just a deletion.
      item = @items.delete_at(@cursor.top)
      item.children.reverse_each { |c| @items.insert(@cursor.top, c) }
      clamp_cursor
    end
  end

  def task_at_cursor
    item = @cursor.resolve(@items)
    item ? item.text.chomp : ""
  end

  def tag_tallies
    filter_tasks(:select).freq
  end

  def untagged_tally
    filter_tasks(:reject).count
  end

  def insert_blank
    @items.insert(@cursor.top, Task.new($/))
    @cursor = Position.top(@cursor.top)
    adjust_page
  end

  def iterative_find_init text
    @last_search_text = text
    found = all_positions.find { |pos| pos.resolve(@items).text =~ /#{Regexp.escape(text)}/i }
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

    found = positions[start_idx..].find { |pos| pos.resolve(@items).text =~ /#{Regexp.escape(text)}/i }
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
    @cursor.on_section_header?(@items)
  end

  def display_label(top_index, child_index = nil)
    (child_index ? Position.child(top_index, child_index) : Position.top(top_index)).label
  end

  # Section mutation methods

  def section_toggle
    return unless cursor_on_section_header?
    item = @items[@cursor.top]
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

    if @cursor.child?
      task = @items[@cursor.top].remove(@cursor.child)
      @items[target_top_index].add(task)
    else
      return if @cursor.top == target_top_index
      task = @items.delete_at(@cursor.top)
      target_top_index -= 1 if @cursor.top < target_top_index
      @items[target_top_index].add(task)
    end

    @items[target_top_index].collapsed = false
    @cursor = Position.child(target_top_index, @items[target_top_index].children.size - 1)
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

  def parse_position line_no
    unless line_no.is_a?(String) && line_no.include?('.')
      return Position.top(line_no.to_i.clamp(0, @items.size - 1))
    end
    top, child = line_no.split('.')
    top, child = top.to_i, child.to_i - 1
    return nil unless top.between?(0, @items.size - 1)
    return nil unless @items[top].section?
    return nil unless child.between?(0, @items[top].children.size - 1)
    Position.child(top, child)
  end

  def all_positions
    positions = []
    @items.each_with_index do |item, i|
      positions << Position.top(i)
      item.children.each_index { |j| positions << Position.child(i, j) }
    end
    positions
  end

  def visible_positions
    positions = []
    @items.each_with_index do |item, i|
      positions << Position.top(i)
      item.children.each_index { |j| positions << Position.child(i, j) } unless item.collapsed
    end
    positions
  end

  def visible_count
    @items.sum { |item| 1 + (item.collapsed ? 0 : item.children.size) }
  end

  def adjust_page
    positions = visible_positions
    idx = positions.index(@cursor) || 0
    @page_no = idx / InteractivePaginator::PAGE_SIZE
  end

  def cursor_char pos
    return " " unless @cursor == pos
    @grab_mode ? "*" : "-"
  end

  def update_task_at_cursor task_text
    item = @cursor.resolve(@items)
    return unless item
    item.text = task_text + $/
  end

  def clamp_cursor
    @cursor = @items.empty? ? Position.top(0)
                            : Position.top([@cursor.top, @items.size - 1].min)
  end

  def zap_target line_no
    return line_no unless line_no.is_a?(String)
    return nil if line_no.include?('.')
    line_no.to_i
  end

  def cursor_after_child_removal pos
    children = @items[pos.top].children
    children.empty? ? Position.top(pos.top)
                    : Position.child(pos.top, [pos.child, children.size - 1].min)
  end

  def step direction
    positions = visible_positions
    idx = positions.index(@cursor) || 0
    @cursor = positions[(idx + direction).clamp(0, positions.size - 1)]
    adjust_page
  end

  def grab_down
    if @cursor.child?
      item = @items[@cursor.top]
      if @cursor.child < item.children.size - 1
        item.children.swap_elements(@cursor.child, @cursor.child + 1)
        @cursor = Position.child(@cursor.top, @cursor.child + 1)
      end
    else
      return if @cursor.top >= @items.size - 1
      @items.swap_elements(@cursor.top, @cursor.top + 1)
      @cursor = Position.top(@cursor.top + 1)
    end
    adjust_page
  end

  def grab_up
    if @cursor.child?
      if @cursor.child > 0
        @items[@cursor.top].children.swap_elements(@cursor.child, @cursor.child - 1)
        @cursor = Position.child(@cursor.top, @cursor.child - 1)
      end
    else
      return if @cursor.top <= 0
      @items.swap_elements(@cursor.top, @cursor.top - 1)
      @cursor = Position.top(@cursor.top - 1)
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
    @items.flat_map { |item| [item.text, *item.children.map(&:text)] }
  end

end
