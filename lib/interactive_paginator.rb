require 'io/console'

class InteractivePaginator
  PAGE_SIZE = 40

  def initialize(io)
    @io = io
  end

  def display_paginated(content)
    lines = content.lines

    # If content is short, just display it normally
    if lines.count <= PAGE_SIZE
      @io.clear_console
      @io.append_to_console(content)
      return content
    end

    # Paginate for longer content with arrow key navigation
    page = 0
    total_pages = (lines.count.to_f / PAGE_SIZE).ceil

    loop do
      start_line = page * PAGE_SIZE
      end_line = [start_line + PAGE_SIZE, lines.count].min
      page_content = lines[start_line...end_line].join

      @io.clear_console
      @io.append_to_console(page_content)

      # Show navigation instructions
      page_indicator = "--- Page #{page + 1} of #{total_pages} (↑/↓ arrows to navigate, q to quit) ---"
      @io.append_to_console($/ + page_indicator + $/)

      # Get raw input to capture arrow keys
      input = get_paginated_input

      case input
      when :up
        page = [page - 1, 0].max
      when :down
        page = [page + 1, total_pages - 1].min
      when :quit
        break
      end
    end

    content
  end

  private

  def get_paginated_input
    # Read raw input character by character to capture arrow keys
    char = STDIN.getch

    # Check for 'q' to quit
    return :quit if char == 'q' || char == 'Q'

    # Check for escape sequence (arrow keys start with ESC)
    if char == "\e"
      # Read the next two characters for arrow key sequence
      char2 = STDIN.getch
      char3 = STDIN.getch

      if char2 == '['
        case char3
        when 'A' # Up arrow
          return :up
        when 'B' # Down arrow
          return :down
        end
      end
    end

    # Default: treat as down (continue forward like before)
    :down
  end
end
