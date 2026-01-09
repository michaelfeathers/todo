require 'io/console'

class InteractivePaginator
  PAGE_SIZE = 40

  def initialize(io)
    @io = io
  end

  def display_paginated(content)
    @lines = content.lines
    @total_pages = (@lines.count.to_f / PAGE_SIZE).ceil

    if fits_on_single_page?
      display_content(content)
    else
      paginate
    end

    content
  end

  private

  def fits_on_single_page?
    @lines.count <= PAGE_SIZE
  end

  def display_content(content)
    @io.clear_console
    @io.append_to_console(content)
  end

  def paginate
    @page = 0

    loop do
      display_current_page
      break if navigate == :quit
    end
  end

  def display_current_page
    display_content(current_page_content)
    @io.append_to_console($/ + page_indicator + $/)
  end

  def current_page_content
    start_line = @page * PAGE_SIZE
    end_line = [start_line + PAGE_SIZE, @lines.count].min
    @lines[start_line...end_line].join
  end

  def page_indicator
    "--- Page #{@page + 1} of #{@total_pages} (↑/↓ arrows, page#, or q to quit) ---"
  end

  def navigate
    input = read_input

    case input
    when :up
      @page = [@page - 1, 0].max
    when :down
      @page = [@page + 1, @total_pages - 1].min
    when :quit
      :quit
    when Integer
      jump_to_page(input)
    end
  end

  def jump_to_page(target)
    @page = target - 1 if target.between?(1, @total_pages)
  end

  def read_input
    char = STDIN.getch

    return :quit if quit_key?(char)
    return read_page_number(char) if digit?(char)
    return read_arrow_key if escape_key?(char)

    :down
  end

  def quit_key?(char)
    char == 'q' || char == 'Q'
  end

  def digit?(char)
    char =~ /[0-9]/
  end

  def escape_key?(char)
    char == "\e"
  end

  def read_page_number(first_digit)
    digits = first_digit

    loop do
      char = STDIN.getch
      break if enter_key?(char)
      return :down unless digit?(char)
      digits += char
    end

    digits.to_i
  end

  def enter_key?(char)
    char == "\r" || char == "\n"
  end

  def read_arrow_key
    return :down unless STDIN.getch == '['

    case STDIN.getch
    when 'A' then :up
    when 'B' then :down
    else :down
    end
  end
end
