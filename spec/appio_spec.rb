require 'spec_helper'
require 'appio'
require 'headlessio'
require 'fakeappio'

describe 'AppIo#display_paginated' do
  context 'when using FakeAppIo' do
    let(:io) { FakeAppIo.new }

    it 'displays content without pagination when less than 40 lines' do
      short_content = (1..30).map { |i| "Line #{i}\n" }.join
      result = io.display_paginated(short_content)
      expect(result).to eq(short_content)
      expect(io.console_output_content).to eq(short_content)
    end

    it 'paginates content when more than 40 lines' do
      long_content = (1..80).map { |i| "Line #{i}\n" }.join
      io.console_input_content = "\n" # User presses enter to continue

      io.display_paginated(long_content)

      # Should show first page
      expect(io.console_output_content).to include("Line 1")
      expect(io.console_output_content).to include("Line 40")
    end

    it 'shows page indicator when there are more pages' do
      long_content = (1..80).map { |i| "Line #{i}\n" }.join
      io.console_input_content = "\n"

      io.display_paginated(long_content)

      expect(io.console_output_content).to include(",,,")
    end

    it 'stops pagination when user enters q' do
      long_content = (1..80).map { |i| "Line #{i}\n" }.join
      io.console_input_content = "q"

      io.display_paginated(long_content)

      # Should only show first page
      expect(io.console_output_content).to include("Line 1")
      expect(io.console_output_content).not_to include("Line 41")
    end
  end

  context 'when using HeadlessIo' do
    let(:headless_io) { HeadlessIo.new }

    before do
      # Mock the console methods
      allow(headless_io).to receive(:clear_console)
      allow(headless_io).to receive(:append_to_console)
    end

    it 'does not paginate even with long content' do
      long_content = (1..80).map { |i| "Line #{i}\n" }.join

      expect(headless_io).to receive(:clear_console)
      expect(headless_io).to receive(:append_to_console).with(long_content)
      expect(headless_io).not_to receive(:get_from_console)

      result = headless_io.display_paginated(long_content)
      expect(result).to eq(long_content)
    end

    it 'displays short content normally' do
      short_content = (1..30).map { |i| "Line #{i}\n" }.join

      expect(headless_io).to receive(:clear_console)
      expect(headless_io).to receive(:append_to_console).with(short_content)

      result = headless_io.display_paginated(short_content)
      expect(result).to eq(short_content)
    end
  end
end

describe 'AppIo::PAGE_SIZE' do
  it 'is set to 40' do
    expect(AppIo::PAGE_SIZE).to eq(40)
  end
end

describe 'AppIo#should_save_to_history?' do
  let(:io) { AppIo.new }

  before do
    # Clear history before each test
    Readline::HISTORY.clear
  end

  it 'does not save empty input' do
    expect(io.send(:should_save_to_history?, '')).to eq(false)
    expect(io.send(:should_save_to_history?, '   ')).to eq(false)
  end

  it 'does not save the quit command' do
    expect(io.send(:should_save_to_history?, 'q')).to eq(false)
    expect(io.send(:should_save_to_history?, '  q  ')).to eq(false)
  end

  it 'does not save consecutive duplicates' do
    # Add a command to history
    Readline::HISTORY.push('d')
    expect(io.send(:should_save_to_history?, 'd')).to eq(false)
  end

  it 'saves non-duplicate commands' do
    Readline::HISTORY.push('u')
    expect(io.send(:should_save_to_history?, 'd')).to eq(true)
  end

  it 'saves regular commands' do
    expect(io.send(:should_save_to_history?, 's')).to eq(true)
    expect(io.send(:should_save_to_history?, 'a task description')).to eq(true)
  end
end
