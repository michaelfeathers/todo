require 'spec_helper'
require 'interactive_paginator'

class FakeInteractiveIo
  attr_accessor :output, :input_sequence

  def initialize
    @output = ""
    @input_sequence = []
    @input_index = 0
  end

  def append_to_console(text)
    @output += text
  end

  def clear_console
    @output = ""
  end

  def get_next_input
    char = @input_sequence[@input_index]
    @input_index += 1
    char
  end
end

describe InteractivePaginator do
  let(:io) { FakeInteractiveIo.new }
  let(:paginator) { InteractivePaginator.new(io) }

  describe '::PAGE_SIZE' do
    it 'is set to 40' do
      expect(InteractivePaginator::PAGE_SIZE).to eq(40)
    end
  end

  describe '#display_paginated' do
    context 'with short content (less than PAGE_SIZE)' do
      it 'displays all content without pagination' do
        content = (1..30).map { |i| "Line #{i}\n" }.join

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to eq(content)
      end
    end

    context 'with long content (more than PAGE_SIZE)' do
      before do
        allow(STDIN).to receive(:getch) do
          io.get_next_input
        end
      end

      it 'displays first page and quits when user presses q' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['q']

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 1")
        expect(io.output).to include("Line 40")
        expect(io.output).to include("Page 1 of 2")
      end

      it 'navigates to next page with down arrow' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'B', 'q']  # Down arrow, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 41")
        expect(io.output).to include("Page 2 of 2")
      end

      it 'navigates to previous page with up arrow' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'B', "\e", '[', 'A', 'q']  # Down, Up, quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 1 of 2")
      end

      it 'does not go below page 0 when pressing up on first page' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'A', "\e", '[', 'A', 'q']  # Up arrow twice on first page, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 1 of 2")
      end

      it 'does not go beyond last page when pressing down' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'B', "\e", '[', 'B', 'q']  # Down arrow twice, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 2 of 2")
      end

      it 'handles multiple pages correctly' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'B', "\e", '[', 'B', 'q']  # Navigate to page 3, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 81")
        expect(io.output).to include("Page 3 of 3")
      end

      it 'treats Q (uppercase) as quit' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['Q']

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 1 of 2")
      end

      it 'treats unknown input as down (continue)' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['x', 'q']  # Unknown char, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 2 of 2")
      end

      it 'handles incomplete escape sequences as down' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", 'x', 'y', 'q']  # Incomplete escape sequence

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
      end

      it 'handles unknown arrow key codes as down' do
        content = (1..80).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'C', 'q']  # Right arrow (C) treated as down

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 2 of 2")
      end

      it 'jumps to page 2 when user types "2" followed by return' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['2', "\n", 'q']  # Type "2" + Enter, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 41")
        expect(io.output).to include("Page 2 of 3")
      end

      it 'jumps to page 3 when user types "3" followed by return' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['3', "\n", 'q']  # Type "3" + Enter, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 81")
        expect(io.output).to include("Page 3 of 3")
      end

      it 'jumps to page 1 when user types "1" followed by return' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ["\e", '[', 'B', '1', "\n", 'q']  # Navigate down, then jump to page 1, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 1")
        expect(io.output).to include("Page 1 of 3")
      end

      it 'handles multi-digit page numbers' do
        content = (1..500).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['1', '0', "\n", 'q']  # Type "10" + Enter, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 361")
        expect(io.output).to include("Page 10 of 13")
      end

      it 'does nothing (noop) when user enters invalid page number (too high)' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['9', '9', "\n", 'q']  # Type "99" + Enter (invalid), then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 1 of 3")  # Should still be on page 1
      end

      it 'does nothing (noop) when user enters page number 0' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['0', "\n", 'q']  # Type "0" + Enter (invalid), then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Page 1 of 3")  # Should still be on page 1
      end

      it 'works with carriage return instead of newline' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['2', "\r", 'q']  # Type "2" + CR, then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to include("Line 41")
        expect(io.output).to include("Page 2 of 3")
      end

      it 'treats digit followed by non-digit as down (noop)' do
        content = (1..120).map { |i| "Line #{i}\n" }.join
        io.input_sequence = ['2', 'x', 'q']  # Type "2" followed by invalid char 'x', then quit

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        # Should advance one page (down behavior) since invalid input
        expect(io.output).to include("Page 2 of 3")
      end
    end

    context 'with exactly PAGE_SIZE lines' do
      it 'displays all content without pagination' do
        content = (1..40).map { |i| "Line #{i}\n" }.join

        result = paginator.display_paginated(content)

        expect(result).to eq(content)
        expect(io.output).to eq(content)
        expect(io.output).not_to include("Page")
      end
    end
  end
end
